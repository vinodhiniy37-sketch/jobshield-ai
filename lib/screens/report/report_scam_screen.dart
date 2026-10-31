import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/mock_data_service.dart';

class ReportScamScreen extends StatefulWidget {
  final String? initialCompany;
  final String? initialUrl;
  final String? initialDesc;

  const ReportScamScreen({
    Key? key,
    this.initialCompany,
    this.initialUrl,
    this.initialDesc,
  }) : super(key: key);

  @override
  State<ReportScamScreen> createState() => _ReportScamScreenState();
}

class _ReportScamScreenState extends State<ReportScamScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _websiteController;
  late final TextEditingController _urlController;
  late final TextEditingController _descController;

  String _selectedCategory = 'Check Cashing Fraud';
  Uint8List? _screenshotBytes;
  String? _screenshotName;
  Uint8List? _proofBytes;
  String? _proofName;
  double? _proofSizeKb;
  bool _isLoading = false;

  final List<String> _categories = [
    'Check Cashing Fraud',
    'Advance Fee Scams',
    'Identity Theft / Harvesting',
    'Telegram/WhatsApp Phishing',
    'Fake Training Fees',
    'Other Recruiter Phishing',
  ];

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.initialCompany);
    _websiteController = TextEditingController();
    _urlController = TextEditingController(text: widget.initialUrl);
    _descController = TextEditingController(text: widget.initialDesc);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _websiteController.dispose();
    _urlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) return;
        setState(() {
          _screenshotBytes = file.bytes;
          _screenshotName = file.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected screenshot: ${file.name}')),
        );
      }
    } catch (e) {
      debugPrint('Error picking screenshot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick screenshot file.')),
      );
    }
  }

  Future<void> _pickProof() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) return;
        setState(() {
          _proofBytes = file.bytes;
          _proofName = file.name;
          _proofSizeKb = file.size / 1024.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected proof: ${file.name}')),
        );
      }
    } catch (e) {
      debugPrint('Error picking proof: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick proof file.')),
      );
    }
  }

  void _onSubmitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final service = Provider.of<MockDataService>(context, listen: false);
      final success = await service.submitScamReport(
        companyName: _companyController.text.trim(),
        website: _websiteController.text.trim(),
        jobUrl: _urlController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        screenshotName: _screenshotName,
        screenshotBytes: _screenshotBytes,
        proofName: _proofName,
        proofBytes: _proofBytes,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {

        // Confirmation modal
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success),
                SizedBox(width: 8),
                Text('Report Filed'),
              ],
            ),
            content: const Text(
              'Thank you. Your scam report has been logged in our databases. Our verification agents will evaluate the details shortly to update threat alerts for the community.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit threat report. Please verify connection or fields.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Scam threat'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flag Fraudulent Employer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'Submit details about fake jobs, phishing recruiters, or check scams. Your reports help block active scam campaigns for everyone.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Company Name
                CustomTextField(
                  label: 'Scam Company / Employer Name *',
                  hintText: 'e.g. Apex Recruiting Agency',
                  controller: _companyController,
                  prefixIcon: Icons.business_rounded,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Company Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Company Website
                CustomTextField(
                  label: 'Company Website (If known)',
                  hintText: 'e.g. www.apex-recruitment.com',
                  controller: _websiteController,
                  prefixIcon: Icons.language_rounded,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),

                // Job URL
                CustomTextField(
                  label: 'Job Posting URL (If active)',
                  hintText: 'e.g. https://linkedin.com/jobs/...',
                  controller: _urlController,
                  prefixIcon: Icons.link_rounded,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),

                // Scam Category Dropdown
                Text(
                  'Scam Threat Category *',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Description
                CustomTextField(
                  label: 'Describe the Scam Method *',
                  hintText: 'Provide details like: Recruiter username, Telegram handle, fake check amounts, or messages asking you to pay fees...',
                  controller: _descController,
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please describe the scam method';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Evidence uploading
                const Text(
                  'Attach Evidence (Screenshots / PDFs / Emails)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickScreenshot,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _screenshotName != null
                                  ? AppColors.success
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.screenshot_rounded,
                                color: _screenshotName != null ? AppColors.success : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _screenshotName == null ? 'Screenshot' : 'Selected ✓',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _screenshotName != null ? AppColors.success : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickProof,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _proofName != null
                                  ? AppColors.success
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                color: _proofName != null ? AppColors.success : AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _proofName == null ? 'Proof (PDF/Txt)' : 'Selected ✓',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _proofName != null ? AppColors.success : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_screenshotName != null || _proofName != null) ...[
                  const SizedBox(height: 12),
                  if (_screenshotName != null)
                    Chip(
                      label: Text(_screenshotName!, style: const TextStyle(fontSize: 11)),
                      onDeleted: () => setState(() {
                        _screenshotName = null;
                        _screenshotBytes = null;
                      }),
                    ),
                  if (_proofName != null)
                    Chip(
                      label: Text(
                        _proofSizeKb != null
                            ? '$_proofName (${_proofSizeKb!.toStringAsFixed(1)} KB)'
                            : _proofName!,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onDeleted: () => setState(() {
                        _proofName = null;
                        _proofBytes = null;
                        _proofSizeKb = null;
                      }),
                    ),
                ],

                const SizedBox(height: 36),

                // Submit Action
                CustomButton(
                  text: 'Submit Threat Report',
                  isLoading: _isLoading,
                  onPressed: _onSubmitReport,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
