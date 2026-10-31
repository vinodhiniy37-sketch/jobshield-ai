import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/mock_data_service.dart';
import '../screens/scan/scan_job_screen.dart';
import '../screens/resume/ats_resume_scanner_screen.dart';
import '../screens/resume/ats_job_match_screen.dart';
import '../screens/linkedin/linkedin_optimizer_screen.dart';
import '../screens/cover_letter/cover_letter_generator_screen.dart';
import '../screens/jobs/jobs_hub_screen.dart';
import '../screens/interview/interview_coach_screen.dart';

class CareerJourneyStepper extends StatelessWidget {
  const CareerJourneyStepper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final currentStep = service.currentWorkflowStep;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      {'step': WorkflowStep.scan, 'num': '1', 'label': 'Scan', 'icon': Icons.security_rounded},
      {'step': WorkflowStep.resume, 'num': '2', 'label': 'Resume', 'icon': Icons.description_rounded},
      {'step': WorkflowStep.jobMatch, 'num': '3', 'label': 'Match', 'icon': Icons.compare_arrows_rounded},
      {'step': WorkflowStep.linkedIn, 'num': '4', 'label': 'LinkedIn', 'icon': Icons.workspace_premium_rounded},
      {'step': WorkflowStep.coverLetter, 'num': '5', 'label': 'Letter', 'icon': Icons.edit_document},
      {'step': WorkflowStep.jobs, 'num': '6', 'label': 'Jobs', 'icon': Icons.work_rounded},
      {'step': WorkflowStep.tracker, 'num': '7', 'label': 'Tracker', 'icon': Icons.assignment_turned_in_rounded},
      {'step': WorkflowStep.interview, 'num': '8', 'label': 'Interview', 'icon': Icons.record_voice_over_rounded},
    ];

    int currentIndex = steps.indexWhere((s) => s['step'] == currentStep);
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D172E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2D4F) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFF3B82F6), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'CAREER JOURNEY PROGRESS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? const Color(0xFF93C5FD) : AppColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                'Step ${currentIndex + 1} of ${steps.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Stepper Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final data = entry.value;
                final stepEnum = data['step'] as WorkflowStep;
                final isCompleted = idx < currentIndex;
                final isCurrent = idx == currentIndex;

                Color pillBg;
                Color textColor;
                BorderSide border;

                if (isCurrent) {
                  pillBg = const Color(0xFF2563EB);
                  textColor = Colors.white;
                  border = BorderSide.none;
                } else if (isCompleted) {
                  pillBg = const Color(0xFF10B981).withOpacity(0.15);
                  textColor = const Color(0xFF10B981);
                  border = const BorderSide(color: Color(0xFF10B981), width: 1);
                } else {
                  pillBg = isDark ? const Color(0xFF091024) : Colors.grey.shade100;
                  textColor = const Color(0xFF64748B);
                  border = BorderSide(color: isDark ? const Color(0xFF1E2D4F) : Colors.grey.shade300);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _navigateToStep(context, service, stepEnum),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.fromBorderSide(border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCompleted) ...[
                            const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                          ] else ...[
                            Icon(data['icon'] as IconData, size: 14, color: textColor),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            data['label'] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStep(BuildContext context, MockDataService service, WorkflowStep step) {
    service.setWorkflowStep(step);
    final activeJob = service.activeWorkflowJob;

    switch (step) {
      case WorkflowStep.scan:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanJobScreen()));
        break;
      case WorkflowStep.resume:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsResumeScannerScreen()));
        break;
      case WorkflowStep.jobMatch:
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
        break;
      case WorkflowStep.linkedIn:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkedInOptimizerScreen()));
        break;
      case WorkflowStep.coverLetter:
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
        break;
      case WorkflowStep.jobs:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsHubScreen()));
        break;
      case WorkflowStep.tracker:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsHubScreen()));
        break;
      case WorkflowStep.interview:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InterviewCoachScreen(
              initialRole: activeJob?.jobTitle,
              initialCompany: activeJob?.companyName,
            ),
          ),
        );
        break;
    }
  }
}
