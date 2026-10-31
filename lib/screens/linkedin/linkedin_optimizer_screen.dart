import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/linkedin_profile_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/career_journey_stepper.dart';
import '../cover_letter/cover_letter_generator_screen.dart';

class LinkedInOptimizerScreen extends StatefulWidget {
  const LinkedInOptimizerScreen({Key? key}) : super(key: key);

  @override
  State<LinkedInOptimizerScreen> createState() => _LinkedInOptimizerScreenState();
}

class _LinkedInOptimizerScreenState extends State<LinkedInOptimizerScreen> {
  final _headlineController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();
  final _projectController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cp = Provider.of<MockDataService>(context, listen: false).careerProfile;
      if (_headlineController.text.isEmpty && cp.headline.isNotEmpty) {
        _headlineController.text = cp.headline;
      } else if (_headlineController.text.isEmpty) {
        _headlineController.text = 'CSE Student | Flutter Developer';
      }

      if (_aboutController.text.isEmpty && cp.summary.isNotEmpty) {
        _aboutController.text = cp.summary;
      }
      if (_skillsController.text.isEmpty && cp.skills.isNotEmpty) {
        _skillsController.text = cp.skills.join(', ');
      }
    });
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  void _runOptimization() {
    final service = Provider.of<MockDataService>(context, listen: false);
    final headline = _headlineController.text.trim();
    final about = _aboutController.text.trim();
    final skills = _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (headline.isEmpty && about.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your headline or about section text to optimize.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      service.runLinkedInOptimization(
        headline: headline,
        about: about,
        skills: skills,
        projects: _projectController.text.trim(),
      );
      setState(() => _isAnalyzing = false);
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
    final linkedin = service.latestLinkedInAnalysis;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn Profile Optimizer'),
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
                    Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Profile Optimization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 4),
                          Text(
                            'Analyze your LinkedIn headline, summary, and projects for maximum recruiter search ranking.',
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
                      label: 'LinkedIn Headline',
                      hintText: 'e.g. CSE Student | Flutter Developer | AI & Cybersecurity Enthusiast',
                      controller: _headlineController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'About / Summary Section',
                      hintText: 'Paste your current About section paragraph...',
                      controller: _aboutController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Top Technical Skills (Comma Separated)',
                      hintText: 'e.g. Flutter, Dart, Firebase, SQL, REST APIs',
                      controller: _skillsController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Featured Project Description',
                      hintText: 'Paste project summary bullet points...',
                      controller: _projectController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: _isAnalyzing ? 'Optimizing Profile...' : 'Analyze & Optimize LinkedIn Profile',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: _isAnalyzing ? null : _runOptimization,
                    ),
                  ],
                ),
              ),

              if (linkedin != null) ...[
                const SizedBox(height: 24),
                // Score Summary Card
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
                        'LinkedIn Profile Index',
                        style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${linkedin.overallScore}/100',
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: _getScoreColor(linkedin.overallScore)),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildScoreColumn('Headline', linkedin.headlineScore),
                          _buildScoreColumn('About', linkedin.aboutScore),
                          _buildScoreColumn('Keywords', linkedin.keywordScore),
                          _buildScoreColumn('Completeness', linkedin.profileCompletenessScore),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Before -> After Improvement Cards
                const Text('Before → After Optimization Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...linkedin.suggestions.map((s) => _buildBeforeAfterCard(s, isDark)),
                const SizedBox(height: 16),

                // Recommended Keywords
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
                      const Text('Recommended Search Keywords', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: linkedin.recommendedKeywords.map((kw) => Chip(
                          avatar: const Icon(Icons.add, size: 14, color: AppColors.primary),
                          label: Text(kw, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide.none,
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── AUTOMATIC NEXT STEP: COVER LETTER GENERATOR ─────────────────────
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
                            child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Workflow Action: Step 5 (Cover Letter)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  'Generate an AI-tailored professional cover letter for your target role.',
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
                            service.activeWorkflowJob != null
                                ? 'GENERATE COVER LETTER (${service.activeWorkflowJob!.jobTitle}) →'
                                : 'GENERATE COVER LETTER →',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            service.setWorkflowStep(WorkflowStep.coverLetter);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CoverLetterGeneratorScreen(
                                  initialJobTitle: service.activeWorkflowJob?.jobTitle,
                                  initialCompanyName: service.activeWorkflowJob?.companyName,
                                  initialJobDescription: service.activeWorkflowJob?.jobDescription,
                                ),
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

  Widget _buildScoreColumn(String label, int score) {
    return Column(
      children: [
        Text('$score%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _getScoreColor(score))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildBeforeAfterCard(LinkedInSuggestion s, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                s.field == 'Headline' ? Icons.title_rounded : (s.field == 'About Section' ? Icons.notes_rounded : Icons.star_outline_rounded),
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text('Improve ${s.field}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          // Current (Before)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT (BEFORE)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger)),
                const SizedBox(height: 4),
                Text(s.current, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Suggested (After)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SUGGESTED OPTIMIZATION (AFTER)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                const SizedBox(height: 4),
                SelectableText(s.suggested, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Rationale: ${s.rationale}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
