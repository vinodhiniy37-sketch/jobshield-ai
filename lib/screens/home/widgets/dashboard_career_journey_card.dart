import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../services/mock_data_service.dart';
import '../../scan/scan_job_screen.dart';
import '../../resume/ats_resume_scanner_screen.dart';
import '../../resume/ats_job_match_screen.dart';
import '../../linkedin/linkedin_optimizer_screen.dart';
import '../../cover_letter/cover_letter_generator_screen.dart';
import '../../jobs/jobs_hub_screen.dart';
import '../../interview/interview_coach_screen.dart';

class DashboardCareerJourneyCard extends StatelessWidget {
  const DashboardCareerJourneyCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final currentStep = service.currentWorkflowStep;
    final activeJob = service.activeWorkflowJob;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title;
    String subtitle;
    String btnLabel;
    IconData btnIcon;
    VoidCallback onTap;

    final company = activeJob?.companyName ?? 'Target Company';
    final role = activeJob?.jobTitle ?? 'Job Opportunity';

    switch (currentStep) {
      case WorkflowStep.scan:
        title = 'Start Your Career Journey';
        subtitle = 'Scan a job opportunity to verify safety and begin application preparation.';
        btnLabel = 'SCAN A JOB NOW →';
        btnIcon = Icons.security_rounded;
        onTap = () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanJobScreen()));
        };
        break;

      case WorkflowStep.resume:
        title = 'Job Safety Scan Verified ✓';
        subtitle = 'Safety check complete for $company ($role). Next: Check your resume compatibility.';
        btnLabel = 'UPLOAD / CHECK RESUME →';
        btnIcon = Icons.description_rounded;
        onTap = () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsResumeScannerScreen()));
        };
        break;

      case WorkflowStep.jobMatch:
        title = 'Resume Analysis Complete ✓';
        subtitle = 'Your resume is analyzed. Next: Match your profile directly against $role at $company.';
        btnLabel = 'CHECK ATS JOB MATCH →';
        btnIcon = Icons.compare_arrows_rounded;
        onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AtsJobMatchScreen(
                initialJobTitle: activeJob?.jobTitle,
                initialCompanyName: activeJob?.companyName,
                initialJobDescription: activeJob?.jobDescription,
              ),
            ),
          );
        };
        break;

      case WorkflowStep.linkedIn:
        title = 'Job Match Analyzed ✓';
        subtitle = 'ATS match complete. Next: Optimize your LinkedIn profile for $role targets.';
        btnLabel = 'OPTIMIZE LINKEDIN PROFILE →';
        btnIcon = Icons.workspace_premium_rounded;
        onTap = () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkedInOptimizerScreen()));
        };
        break;

      case WorkflowStep.coverLetter:
        title = 'LinkedIn Profile Ready ✓';
        subtitle = 'Next: Generate a tailored, professional cover letter for $company ($role).';
        btnLabel = 'GENERATE COVER LETTER →';
        btnIcon = Icons.edit_note_rounded;
        onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoverLetterGeneratorScreen(
                initialJobTitle: activeJob?.jobTitle,
                initialCompanyName: activeJob?.companyName,
                initialJobDescription: activeJob?.jobDescription,
              ),
            ),
          );
        };
        break;

      case WorkflowStep.jobs:
        title = 'Cover Letter Generated ✓';
        subtitle = 'Cover letter ready. Next: Discover similar verified career opportunities.';
        btnLabel = 'FIND SIMILAR JOBS →';
        btnIcon = Icons.work_rounded;
        onTap = () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsHubScreen()));
        };
        break;

      case WorkflowStep.tracker:
        title = 'Application Prepared ✓';
        subtitle = 'Application materials ready. Next: Track status in Application Kanban Tracker.';
        btnLabel = 'OPEN JOB TRACKER →';
        btnIcon = Icons.assignment_turned_in_rounded;
        onTap = () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsHubScreen()));
        };
        break;

      case WorkflowStep.interview:
        title = 'Application In Progress 🎯';
        subtitle = 'Interview stage reached! Next: Practice AI-tailored interview questions for $role.';
        btnLabel = 'START INTERVIEW PREP →';
        btnIcon = Icons.record_voice_over_rounded;
        onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InterviewCoachScreen(
                initialRole: activeJob?.jobTitle,
                initialCompany: activeJob?.companyName,
              ),
            ),
          );
        };
        break;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.stars_rounded, color: Color(0xFFA5B4FC), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                '🎯 CAREER JOURNEY — NEXT RECOMMENDED ACTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFA5B4FC),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFE0E7FF),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(btnIcon, size: 18, color: const Color(0xFF312E81)),
                  const SizedBox(width: 10),
                  Text(
                    btnLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF312E81),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
