import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/career_journey_stepper.dart';
import '../linkedin/linkedin_optimizer_screen.dart';
import '../cover_letter/cover_letter_generator_screen.dart';

class AtsJobMatchScreen extends StatefulWidget {
  final String? initialJobTitle;
  final String? initialCompanyName;
  final String? initialJobDescription;

  const AtsJobMatchScreen({
    Key? key,
    this.initialJobTitle,
    this.initialCompanyName,
    this.initialJobDescription,
  }) : super(key: key);

  @override
  State<AtsJobMatchScreen> createState() => _AtsJobMatchScreenState();
}

class _AtsJobMatchScreenState extends State<AtsJobMatchScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _companyController;
  late final TextEditingController _descController;
  final _resumeController = TextEditingController();
  bool _isMatching = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialJobTitle ?? '');
    _companyController = TextEditingController(text: widget.initialCompanyName ?? '');
    _descController = TextEditingController(text: widget.initialJobDescription ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  void _runJobMatch() {
    final service = Provider.of<MockDataService>(context, listen: false);
    final desc = _descController.text.trim();

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste a job description to match your resume against.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isMatching = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      final resumeText = _resumeController.text.trim().isNotEmpty
          ? _resumeController.text.trim()
          : service.careerProfile.skills.join(' ') + ' ' + service.careerProfile.summary + ' ' + service.careerProfile.projects.join(' ');

      service.runJobMatch(
        resumeText: resumeText,
        jobTitle: _titleController.text.trim(),
        companyName: _companyController.text.trim(),
        jobDescription: desc,
      );

      setState(() => _isMatching = false);
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);
    final match = service.latestJobMatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATS Job Description Match'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CareerJourneyStepper(),
              const SizedBox(height: 16),
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.compare_arrows_rounded, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resume vs Job Matcher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 4),
                          Text(
                            'Compare your candidate profile or resume against target job requirements to identify missing skills and keyword gaps.',
                            style: TextStyle(fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Inputs Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Target Job Title',
                      hintText: 'e.g. Flutter Developer / Software Engineer',
                      controller: _titleController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Company Name',
                      hintText: 'e.g. CloudScale Innovations',
                      controller: _companyController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Paste Target Job Description',
                      hintText: 'Paste the job requirements, qualifications, and required tech stack here...',
                      controller: _descController,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Resume Content (Optional - defaults to Career Profile)',
                      hintText: 'Paste custom resume text or leave empty to use your saved profile skills...',
                      controller: _resumeController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: _isMatching ? 'Matching Resume...' : 'Calculate Job Match Score',
                      icon: Icons.find_in_page_outlined,
                      onPressed: _isMatching ? null : _runJobMatch,
                    ),
                  ],
                ),
              ),

              if (match != null) ...[
                const SizedBox(height: 24),
                // Match Score Gauge Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Target Job Match Score',
                        style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${match.matchScore}%',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _getScoreColor(match.matchScore)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Matched against ${match.companyName} (${match.jobTitle})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Matched & Missing Skills Chips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Matched Technical Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      match.matchedSkills.isEmpty
                          ? const Text('No exact matching skills found.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: match.matchedSkills.map((s) => Chip(
                                avatar: const Icon(Icons.check, size: 14, color: AppColors.success),
                                label: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                backgroundColor: AppColors.success.withOpacity(0.12),
                                side: BorderSide.none,
                              )).toList(),
                            ),
                      const SizedBox(height: 16),
                      const Text('Missing Required Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      match.missingSkills.isEmpty
                          ? const Text('✓ All major required skills matched!', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: match.missingSkills.map((s) => Chip(
                                avatar: const Icon(Icons.close, size: 14, color: AppColors.danger),
                                label: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                backgroundColor: AppColors.danger.withOpacity(0.12),
                                side: BorderSide.none,
                              )).toList(),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Experience Gaps & Recommendations
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Tailored Match Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...match.recommendedChanges.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✓ ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Expanded(child: Text(rec, style: const TextStyle(fontSize: 12, height: 1.3))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── AUTOMATIC NEXT STEP: LINKEDIN OPTIMIZER ─────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D172E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Workflow Action: Step 4 (LinkedIn Optimizer)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  'Optimize your LinkedIn headline and profile for target recruiter matches.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text(
                            'Step 4: OPTIMIZE LINKEDIN PROFILE →',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            service.setWorkflowStep(WorkflowStep.linkedIn);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LinkedInOptimizerScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
