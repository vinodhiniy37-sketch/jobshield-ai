import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../services/mock_data_service.dart';
import '../../../models/job_tracker_model.dart';
import '../../resume/ats_resume_scanner_screen.dart';
import '../../resume/ats_job_match_screen.dart';
import '../../linkedin/linkedin_optimizer_screen.dart';
import '../../tracker/job_tracker_kanban_screen.dart';
import '../../career/career_profile_screen.dart';

class CareerIntelligenceSummary extends StatelessWidget {
  const CareerIntelligenceSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    final profileComp = service.careerProfile.completionPercentage;
    final atsScore = service.latestResumeAnalysis?.overallScore ?? 78;
    final linkedinScore = service.latestLinkedInAnalysis?.overallScore ?? 74;
    final activeAppsCount = service.trackedJobs.where((j) => j.status == ApplicationStatus.applied || j.status == ApplicationStatus.screening).length;
    final interviewsCount = service.trackedJobs.where((j) => j.status == ApplicationStatus.interview || j.status == ApplicationStatus.technicalRound || j.status == ApplicationStatus.hrRound).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Career Metrics Cards Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Career Profile',
                value: '$profileComp%',
                subtitle: 'Completeness',
                icon: Icons.person_pin_rounded,
                color: AppColors.primary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerProfileScreen())),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'ATS Resume',
                value: '$atsScore/100',
                subtitle: 'Est. Score',
                icon: Icons.description_outlined,
                color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsResumeScannerScreen())),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Active Apps',
                value: '$activeAppsCount',
                subtitle: 'In Progress',
                icon: Icons.assignment_outlined,
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobTrackerKanbanScreen())),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'Interviews',
                value: '$interviewsCount',
                subtitle: 'Scheduled',
                icon: Icons.record_voice_over_rounded,
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobTrackerKanbanScreen())),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Your Next Actions Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Text('Your Next Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              if (profileComp < 80)
                _buildActionItem(
                  context,
                  label: 'Complete Career Profile (${80 - profileComp}% remaining)',
                  isDone: false,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerProfileScreen())),
                ),
              _buildActionItem(
                context,
                label: service.latestResumeAnalysis == null ? 'Upload Resume for ATS Score' : 'Optimize Resume Keyword Match',
                isDone: service.latestResumeAnalysis != null,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsResumeScannerScreen())),
              ),
              _buildActionItem(
                context,
                label: service.latestLinkedInAnalysis == null ? 'Analyze LinkedIn Profile Headline' : 'Update LinkedIn Headline & About',
                isDone: service.latestLinkedInAnalysis != null,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkedInOptimizerScreen())),
              ),
              _buildActionItem(
                context,
                label: 'Match Target Job Description for ATS Gaps',
                isDone: service.latestJobMatch != null,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsJobMatchScreen())),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required String label, required bool isDone, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: isDone ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isDone ? Colors.grey : null,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
