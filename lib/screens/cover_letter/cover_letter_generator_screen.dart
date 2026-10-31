import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/cover_letter_model.dart';
import '../../models/career_document_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/career_journey_stepper.dart';
import '../jobs/jobs_hub_screen.dart';
import '../interview/interview_coach_screen.dart';

class CoverLetterGeneratorScreen extends StatefulWidget {
  final String? initialJobTitle;
  final String? initialCompanyName;
  final String? initialJobDescription;

  const CoverLetterGeneratorScreen({
    Key? key,
    this.initialJobTitle,
    this.initialCompanyName,
    this.initialJobDescription,
  }) : super(key: key);

  @override
  State<CoverLetterGeneratorScreen> createState() => _CoverLetterGeneratorScreenState();
}

class _CoverLetterGeneratorScreenState extends State<CoverLetterGeneratorScreen> {
  final _companyController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _editedTextController = TextEditingController();

  CoverLetterTone _selectedTone = CoverLetterTone.professional;
  GeneratedCoverLetter? _generatedLetter;
  bool _isGenerating = false;
  bool _isEditing = false;
  int _variationCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialJobTitle != null && widget.initialJobTitle!.isNotEmpty) {
      _titleController.text = widget.initialJobTitle!;
    }
    if (widget.initialCompanyName != null && widget.initialCompanyName!.isNotEmpty) {
      _companyController.text = widget.initialCompanyName!;
    }
    if (widget.initialJobDescription != null && widget.initialJobDescription!.isNotEmpty) {
      _descController.text = widget.initialJobDescription!;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _editedTextController.dispose();
    super.dispose();
  }

  void _generateCoverLetter() {
    final service = Provider.of<MockDataService>(context, listen: false);
    final company = _companyController.text.trim();
    final title = _titleController.text.trim();

    if (company.isEmpty || title.isEmpty) {
      if (_generatedLetter == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill out Target Company Name and Job Title.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    setState(() => _isGenerating = true);
    final currentVariation = _variationCount++;

    Future.delayed(const Duration(milliseconds: 500), () {
      final result = service.coverLetterService.generateCoverLetter(
        profile: service.careerProfile,
        companyName: company,
        jobTitle: title,
        jobDescription: _descController.text.trim(),
        tone: _selectedTone,
        variation: currentVariation,
      );

      setState(() {
        _generatedLetter = result;
        _editedTextController.text = result.fullText;
        _isGenerating = false;
        _isEditing = false;
      });
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _editedTextController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cover letter copied to clipboard!'), backgroundColor: AppColors.success),
    );
  }

  void _saveToDocuments() {
    final service = Provider.of<MockDataService>(context, listen: false);
    final doc = CareerDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: service.careerProfile.userId,
      title: 'Cover Letter - ${_companyController.text.trim()}',
      category: 'Cover Letter',
      fileUrl: '',
      fileName: 'Cover_Letter_${_companyController.text.trim()}.txt',
      fileSizeBytes: _editedTextController.text.length,
      uploadDate: DateTime.now(),
      content: _editedTextController.text,
    );
    service.addCareerDocument(doc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved cover letter to Career Documents!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Cover Letter Generator'),
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
                    Icon(Icons.edit_document, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tailored Cover Letter Generator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 4),
                          Text(
                            'Generate candidate-specific cover letters customized for target job roles using your authentic profile skills.',
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
                      label: 'Target Company Name',
                      hintText: 'e.g. Apex Tech Solutions',
                      controller: _companyController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Target Job Title',
                      hintText: 'e.g. Flutter Developer Intern',
                      controller: _titleController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Job Description Details (Optional)',
                      hintText: 'Paste key job posting details to customize paragraph alignment...',
                      controller: _descController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Tone & Style', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: CoverLetterTone.values.map((t) {
                        final isSelected = _selectedTone == t;
                        return ChoiceChip(
                          label: Text(t.label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black))),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedTone = t),
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: _isGenerating ? 'Generating Letter...' : 'Generate Cover Letter',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: _isGenerating ? null : _generateCoverLetter,
                    ),
                  ],
                ),
              ),

              if (_generatedLetter != null) ...[
                const SizedBox(height: 24),
                // Generated Letter Display Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Generated Cover Letter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_note_rounded, color: AppColors.primary),
                            onPressed: () => setState(() => _isEditing = !_isEditing),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isEditing
                          ? TextField(
                              controller: _editedTextController,
                              maxLines: 14,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                            )
                          : SelectableText(
                              _editedTextController.text,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Actions: Copy, Save, Regenerate
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text('Copy to Clipboard'),
                            onPressed: _copyToClipboard,
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                            label: const Text('Save Document'),
                            onPressed: _saveToDocuments,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Regenerate'),
                            onPressed: _isGenerating ? null : _generateCoverLetter,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── AUTOMATIC NEXT STEP: JOBS DISCOVERY ─────────────────────
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
                            child: const Icon(Icons.work_outline_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Workflow Action: Step 6 (Jobs Discovery)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  'Browse verified job openings and apply with your optimized resume & cover letter.',
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
                          label: const Text(
                            'Step 6: DISCOVER & APPLY FOR JOBS →',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            service.setWorkflowStep(WorkflowStep.jobs);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JobsHubScreen(),
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
