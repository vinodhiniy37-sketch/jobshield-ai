import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/career_journey_stepper.dart';
import '../resume/ats_resume_scanner_screen.dart';
import '../resume/ats_job_match_screen.dart';
import '../linkedin/linkedin_optimizer_screen.dart';
import '../cover_letter/cover_letter_generator_screen.dart';
import '../interview/interview_coach_screen.dart';
import '../documents/career_documents_screen.dart';
import 'career_profile_screen.dart';

class CareerHubScreen extends StatelessWidget {
  const CareerHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> atsModuleSteps = [
      {
        'id': '01',
        'title': 'ATS Resume Scanner',
        'desc': 'Scan resume, ATS score, formatting & keyword check',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF0284C7),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsResumeScannerScreen())),
      },
      {
        'id': '02',
        'title': 'Job Description Matching',
        'desc': 'Resume vs target job description gap analyzer',
        'icon': Icons.compare_arrows_rounded,
        'color': AppColors.success,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsJobMatchScreen())),
      },
      {
        'id': '03',
        'title': 'LinkedIn Optimizer',
        'desc': 'Headline, summary & keyword enhancer',
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkedInOptimizerScreen())),
      },
    ];

    final List<Map<String, dynamic>> applicationToolkitSteps = [
      {
        'id': '01',
        'title': 'AI Cover Letter Generator',
        'desc': 'Custom tailored cover letters in 4 tones',
        'icon': Icons.edit_document,
        'color': const Color(0xFFD97706),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoverLetterGeneratorScreen())),
      },
      {
        'id': '02',
        'title': 'Interview Coach',
        'desc': 'Role-specific questions & AI answer feedback',
        'icon': Icons.record_voice_over_rounded,
        'color': const Color(0xFF059669),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InterviewCoachScreen())),
      },
      {
        'id': '03',
        'title': 'Career Profile',
        'desc': 'Target roles, skills, education & experience',
        'icon': Icons.account_box_rounded,
        'color': AppColors.primary,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerProfileScreen())),
      },
      {
        'id': '04',
        'title': 'Saved Documents Vault',
        'desc': 'Stored resumes, cover letters & certificates',
        'icon': Icons.folder_special_rounded,
        'color': const Color(0xFF6366F1),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerDocumentsScreen())),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Preparation Hub'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Career Journey Progress Stepper
              const CareerJourneyStepper(),

              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars_rounded, color: Colors.white, size: 26),
                        SizedBox(width: 10),
                        Text(
                          'Career Intelligence Suite',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Optimize your resume, match job requirements, build tailored cover letters, and practice interview skills.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── MODULE 1: ATS & PROFILE MATCH ─────────────────────────────
              Text(
                '🎯 MODULE 1 — ATS & PROFILE MATCH',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 10),
              _buildStepList(context, atsModuleSteps, isDark),

              const SizedBox(height: 24),

              // ── MODULE 2: APPLICATION TOOLKIT ─────────────────────────────
              Text(
                '✍️ MODULE 2 — APPLICATION TOOLKIT',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFFD97706),
                    ),
              ),
              const SizedBox(height: 10),
              _buildStepList(context, applicationToolkitSteps, isDark),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepList(BuildContext context, List<Map<String, dynamic>> steps, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final step = steps[index];
        final String id = step['id'];
        final String title = step['title'];
        final String desc = step['desc'];
        final IconData icon = step['icon'];
        final Color color = step['color'];
        final VoidCallback onTap = step['onTap'];

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    id,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      },
    );
  }
}
