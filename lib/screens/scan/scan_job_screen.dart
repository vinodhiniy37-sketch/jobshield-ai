import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import '../../services/mock_data_service.dart';
import '../../models/job_scan_model.dart';
import '../../models/job_tracker_model.dart';
import '../report/report_scam_screen.dart';
import '../resume/ats_resume_scanner_screen.dart';
import '../resume/ats_job_match_screen.dart';
import '../cover_letter/cover_letter_generator_screen.dart';
import '../interview/interview_coach_screen.dart';
import 'widgets/image_upload_card.dart';

class ScanJobScreen extends StatefulWidget {
  final String? initialJobTitle;
  final String? initialCompanyName;
  final String? initialJobDescription;
  final String? initialJobUrl;
  final String? initialLocation;

  const ScanJobScreen({
    Key? key,
    this.initialJobTitle,
    this.initialCompanyName,
    this.initialJobDescription,
    this.initialJobUrl,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<ScanJobScreen> createState() => _ScanJobScreenState();
}

class _ScanJobScreenState extends State<ScanJobScreen> {
  final _urlController = TextEditingController();
  final _descController = TextEditingController();
  final _companyController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _recruiterEmailController = TextEditingController();
  final _recruiterPlatformController = TextEditingController();
  final _recruiterMessagesController = TextEditingController();

  String? _uploadedFileName;
  String? _uploadedFileType;
  Uint8List? _uploadedFileBytes; // real file bytes from file_picker
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  // No _showResult flag needed — result shows as soon as service.latestScanResult != null

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
    if (widget.initialJobUrl != null && widget.initialJobUrl!.isNotEmpty) {
      _urlController.text = widget.initialJobUrl!;
    }
    if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      _locationController.text = widget.initialLocation!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _descController.dispose();
    _companyController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _recruiterEmailController.dispose();
    _recruiterPlatformController.dispose();
    _recruiterMessagesController.dispose();
    super.dispose();
  }

  // Real file picker — opens browser/native file dialog
  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result;

      if (type == 'pdf') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          withData: true, // Required for web to load bytes
        );
      } else {
        // Email / text files
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'txt', 'eml', 'msg', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
          withData: true,
        );
      }

      if (result == null || result.files.isEmpty) return; // user cancelled

      final file = result.files.first;
      final bytes = file.bytes;
      final name = file.name;

      if (bytes == null) {
        _showUploadError('Could not read file data. Please try a different file.');
        return;
      }

      // Size limit: 10 MB
      if (bytes.length > 10 * 1024 * 1024) {
        _showUploadError('File is too large. Maximum allowed size is 10 MB.');
        return;
      }

      setState(() {
        _uploadedFileName = name;
        _uploadedFileType = type;
        _uploadedFileBytes = bytes;
        // Clear any image selection when a document is picked
        _selectedImageFile = null;
        _selectedImageBytes = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$name" ready for scanning.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      _showUploadError('Failed to pick file: ${e.toString()}');
    }
  }

  void _showUploadError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _removeUpload() {
    setState(() {
      _uploadedFileName = null;
      _uploadedFileType = null;
      _uploadedFileBytes = null;
      _selectedImageFile = null;
      _selectedImageBytes = null;
    });
  }

  void _previewUpload() {
    if (_uploadedFileName == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Preview: $_uploadedFileName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 24),
              Icon(
                _uploadedFileType == 'pdf'
                    ? Icons.picture_as_pdf_rounded
                    : (_uploadedFileType == 'image' ? Icons.image_rounded : Icons.description_rounded),
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Simulated File Preview',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'File Content: Mock data matching employment documents and terms.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startScan() async {
    final service = Provider.of<MockDataService>(context, listen: false);

    // Clear any previous result so UI returns to form while scanning
    service.clearScanResult();

    // If an image is selected, scan it with the form data included
    if (_selectedImageFile != null && _selectedImageBytes != null) {
      await service.runJobScan(
        companyName: _companyController.text.trim().isEmpty
            ? 'Image Scan'
            : _companyController.text.trim(),
        jobTitle: _titleController.text.trim().isEmpty
            ? 'Scanned Document/Screenshot'
            : _titleController.text.trim(),
        jobUrl: _urlController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? 'Analyzed from uploaded screenshot: ${_selectedImageFile!.name}'
            : '${_descController.text.trim()}\n\n[Attached screenshot: ${_selectedImageFile!.name}]',
        jobLocation: _locationController.text.trim(),
        salary: _salaryController.text.trim(),
        recruiterEmail: _recruiterEmailController.text.trim(),
        recruiterPlatform: _recruiterPlatformController.text.trim(),
        recruiterMessages: _recruiterMessagesController.text.trim(),
        fileBaseName: _selectedImageFile!.name,
        fileExtension: 'image',
        fileBytes: _selectedImageBytes,
      );
      return;
    }

    if (_companyController.text.trim().isEmpty &&
        _descController.text.trim().isEmpty &&
        _urlController.text.trim().isEmpty &&
        _recruiterEmailController.text.trim().isEmpty &&
        _uploadedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please provide a Company Name, Job URL, Description, Recruiter details, or file to scan.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    await service.runJobScan(
      companyName: _companyController.text.trim(),
      jobTitle: _titleController.text.trim(),
      jobUrl: _urlController.text.trim(),
      description: _descController.text.trim(),
      jobLocation: _locationController.text.trim(),
      salary: _salaryController.text.trim(),
      recruiterEmail: _recruiterEmailController.text.trim(),
      recruiterPlatform: _recruiterPlatformController.text.trim(),
      recruiterMessages: _recruiterMessagesController.text.trim(),
      fileBaseName: _uploadedFileName,
      fileExtension: _uploadedFileType,
      filePath: null,
      fileBytes: _uploadedFileBytes,
    );
  }

  Color _getStatusColor(ScanStatus status) {
    switch (status) {
      case ScanStatus.safe:
        return const Color(0xFF10B981);
      case ScanStatus.lowRisk:
        return const Color(0xFF38BDF8);
      case ScanStatus.suspicious:
        return const Color(0xFFF59E0B);
      case ScanStatus.highRisk:
        return const Color(0xFFF97316);
      case ScanStatus.scam:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    Widget activeBody;

    if (service.isScanning) {
      // Loading State Display
      activeBody = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PulseLoading(size: 110),
              const SizedBox(height: 40),
              Text(
                'Guard AI Scan In Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 250,
                child: LinearProgressIndicator(
                  value: service.scanProgress,
                  backgroundColor: isDark ? AppColors.borderDark : Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                service.scanProgress < 0.3
                    ? 'Connecting to security server...'
                    : (service.scanProgress < 0.6
                        ? 'Analyzing domain registry age...'
                        : 'Reviewing description for payment triggers...'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    } else if (!service.isScanning && service.latestScanResult != null) {
      // Results State Display
      final JobScan result = service.latestScanResult!;
      final statusColor = _getStatusColor(result.status);

      activeBody = SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: statusColor.withOpacity(0.12),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(
                    result.status == ScanStatus.safe
                        ? Icons.verified_user_rounded
                        : (result.status == ScanStatus.suspicious
                            ? Icons.gpp_maybe_rounded
                            : Icons.gpp_bad_rounded),
                    color: statusColor,
                    size: 64,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    result.companyName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    result.jobTitle.isEmpty ? 'Position Details Scanned' : result.jobTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${result.riskPercentage.toStringAsFixed(1)}% Risk Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: statusColor),
                  ),
                  Text(
                    'Verdict: ${result.statusText.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: statusColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Job Location Verification Card
            if (result.location != null && result.location!.isNotEmpty && result.location != 'Not Provided') ...[
              const Text(
                'Job Location Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.location!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    // Location Source Badge
                    if (result.locationSource != null && result.locationSource!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: result.locationSource == 'screenshot'
                              ? AppColors.primary.withOpacity(0.1)
                              : (result.locationSource == 'description'
                                  ? AppColors.warning.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              result.locationSource == 'screenshot'
                                  ? Icons.photo_camera_rounded
                                  : (result.locationSource == 'description'
                                      ? Icons.text_snippet_rounded
                                      : (result.locationSource == 'remote'
                                          ? Icons.wifi_rounded
                                          : Icons.edit_rounded)),
                              size: 14,
                              color: result.locationSource == 'screenshot'
                                  ? AppColors.primary
                                  : (result.locationSource == 'description'
                                      ? AppColors.warning
                                      : AppColors.success),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.locationSource == 'screenshot'
                                  ? 'Detected from screenshot'
                                  : (result.locationSource == 'description'
                                      ? 'Extracted from description'
                                      : (result.locationSource == 'remote'
                                          ? 'Remote work detected'
                                          : 'Entered manually')),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: result.locationSource == 'screenshot'
                                    ? AppColors.primary
                                    : (result.locationSource == 'description'
                                        ? AppColors.warning
                                        : AppColors.success),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          result.locationStatus == 'verified'
                              ? Icons.check_circle_rounded
                              : (result.locationStatus == 'suspicious'
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline_rounded),
                          color: result.locationStatus == 'verified'
                              ? AppColors.success
                              : (result.locationStatus == 'suspicious'
                                  ? AppColors.danger
                                  : AppColors.warning),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            result.locationStatus == 'verified'
                                ? 'Location verified against known offices'
                                : (result.locationStatus == 'suspicious'
                                    ? 'Suspicious location indicators detected'
                                    : 'Location could not be independently verified'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: result.locationStatus == 'verified'
                                  ? AppColors.success
                                  : (result.locationStatus == 'suspicious'
                                      ? AppColors.danger
                                      : AppColors.warning),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Location Suggestion
                    if (result.locationSuggestion != null && result.locationSuggestion!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.locationSuggestion!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (result.locationSource == 'screenshot' || (result.location != null && result.location == 'Not clearly visible')) ...[
              // Show card even when location wasn't detected from screenshot
              const Text(
                'Job Location Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_camera_rounded, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'No clear location detected in screenshot',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (result.locationSuggestion != null && result.locationSuggestion!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.locationSuggestion!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Scam Classification Card
            if (result.status == ScanStatus.scam && result.primaryScamType != null && result.primaryScamType!.isNotEmpty) ...[
              const Text(
                'Scam Classification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Primary Type: ',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            _getScamTypeWithEmoji(result.primaryScamType!),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (result.scamTypes != null && result.scamTypes!.length > 1) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      const Text(
                        'Additional Scam Indicators:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ...result.scamTypes!
                          .where((t) => t != result.primaryScamType)
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  _getScamTypeWithEmoji(t),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ],

            // Detected Indicators with Severity Chips
            if (result.indicators.isNotEmpty) ...[
              const Text(
                'Detected Indicators',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: result.indicators.map((ind) {
                    final isCrit = ind.severity == 'critical' || ind.severity == 'high';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCrit ? AppColors.danger.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ind.severity.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCrit ? AppColors.danger : AppColors.warning,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ind.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ind.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Explanations Card
            const Text(
              'Security Findings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                children: result.reasons
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: statusColor, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Recommendations Card
            const Text(
              'Guard AI Recommendations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                children: result.recommendations
                    .map(
                      (rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(rec, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Save Result',
                    isSecondary: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Scan results saved successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      final svc = Provider.of<MockDataService>(context, listen: false);
                      svc.clearScanResult();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Report Scam',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportScamScreen(
                            initialCompany: result.companyName,
                            initialUrl: result.jobUrl,
                            initialDesc: result.jobDescription,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ── HIGH RISK JOB WARNING CARD ──────────────────────────────────────────
            if (result.status == ScanStatus.scam && !service.isSafetyWarningAcknowledged) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C0B0B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gpp_bad_rounded, color: Color(0xFFEF4444), size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🚨 HIGH RISK JOB — RECRUITMENT FRAUD DETECTED',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFFCA5A5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Do not proceed with this application, share personal data, or transfer money until the opportunity is independently verified.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFECDD3), height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.report_problem_rounded, size: 15),
                          label: const Text('Report Scam Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportScamScreen(
                                  initialCompany: result.companyName,
                                  initialUrl: result.jobUrl,
                                  initialDesc: result.jobDescription,
                                ),
                              ),
                            );
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.warning_amber_rounded, size: 15),
                          label: const Text('Acknowledge Risk & Proceed Cautiously', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFCA5A5),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            service.acknowledgeSafetyWarning();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Safety warning acknowledged. Use extreme caution.'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // ── NEXT STEPS: CAREER & APPLICATION WORKFLOW ─────────────────────────
            if (result.status == ScanStatus.safe ||
                result.status == ScanStatus.suspicious ||
                service.isSafetyWarningAcknowledged) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D172E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF60A5FA), size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Recommended Action — Resume & ATS Check',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Now that safety check is complete, check your resume compatibility below:',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('STEP 2: UPLOAD / CHECK RESUME →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          service.setActiveWorkflowJob(result);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AtsResumeScannerScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        // ATS Job Match
                        OutlinedButton.icon(
                          icon: const Icon(Icons.compare_arrows_rounded, size: 15),
                          label: const Text('Check ATS Match', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF60A5FA),
                            side: const BorderSide(color: Color(0xFF60A5FA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            service.setActiveWorkflowJob(result);
                            service.setWorkflowStep(WorkflowStep.jobMatch);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AtsJobMatchScreen(
                                  initialJobTitle: result.jobTitle,
                                  initialCompanyName: result.companyName,
                                  initialJobDescription: result.jobDescription,
                                ),
                              ),
                            );
                          },
                        ),

                        // Cover Letter Generator
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_note_rounded, size: 15),
                          label: const Text('Generate Cover Letter', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFA78BFA),
                            side: const BorderSide(color: Color(0xFFA78BFA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            service.setActiveWorkflowJob(result);
                            service.setWorkflowStep(WorkflowStep.coverLetter);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CoverLetterGeneratorScreen(
                                  initialJobTitle: result.jobTitle,
                                  initialCompanyName: result.companyName,
                                  initialJobDescription: result.jobDescription,
                                ),
                              ),
                            );
                          },
                        ),

                        // Interview Practice
                        OutlinedButton.icon(
                          icon: const Icon(Icons.record_voice_over_rounded, size: 15),
                          label: const Text('Interview Practice', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF38BDF8),
                            side: const BorderSide(color: Color(0xFF38BDF8)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            service.setActiveWorkflowJob(result);
                            service.setWorkflowStep(WorkflowStep.interview);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InterviewCoachScreen(
                                  initialRole: result.jobTitle,
                                  initialCompany: result.companyName,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            CustomButton(
              text: 'Scan Another Job',
              isSecondary: true,
              onPressed: () {
                final svc = Provider.of<MockDataService>(context, listen: false);
                svc.clearScanResult();
                setState(() {
                  _companyController.clear();
                  _titleController.clear();
                  _urlController.clear();
                  _descController.clear();
                  _locationController.clear();
                  _uploadedFileBytes = null;
                  _removeUpload();
                });
              },
            ),
          ],
        ),
      );
    } else {
      // Input form State Display
      activeBody = SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Security Scan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              'Input hiring details below. Our security model will score risk exposure, check registry age, and flag advance fee scams.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Company Name
            CustomTextField(
              label: 'Employer / Company Name',
              hintText: 'e.g. Apex Global Solutions',
              controller: _companyController,
              prefixIcon: Icons.business_rounded,
            ),
            const SizedBox(height: 16),

            // Job Title
            CustomTextField(
              label: 'Job Title',
              hintText: 'e.g. Remote Data Entry Assistant',
              controller: _titleController,
              prefixIcon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 16),

            // URL
            CustomTextField(
              label: 'Job Posting URL',
              hintText: 'e.g. https://linkedin.com/jobs/1234',
              controller: _urlController,
              prefixIcon: Icons.language_rounded,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Job Location
            CustomTextField(
              label: 'Job Location (Optional)',
              hintText: 'e.g. Chennai, Tamil Nadu',
              controller: _locationController,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            // Salary
            CustomTextField(
              label: 'Stated Salary / Compensation (Optional)',
              hintText: 'e.g. ₹6,50,000 / yr or \$45/hr',
              controller: _salaryController,
              prefixIcon: Icons.currency_rupee,
            ),
            const SizedBox(height: 16),

            // Description
            CustomTextField(
              label: 'Paste Job Posting Description / Email Text',
              hintText: 'Paste the job requirements, contact instructions, pay description, or email proposal text here...',
              controller: _descController,
              prefixIcon: Icons.description_outlined,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Recruiter Details & Communication Channels
            ExpansionTile(
              initiallyExpanded: false,
              tilePadding: EdgeInsets.zero,
              title: const Row(
                children: [
                  Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recruiter Details & Messages (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              children: [
                const SizedBox(height: 8),
                CustomTextField(
                  label: 'Recruiter Email / Contact',
                  hintText: 'e.g. hr@company.com or recruiter@gmail.com',
                  controller: _recruiterEmailController,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Interview Platform / Channel',
                  hintText: 'e.g. Microsoft Teams, Google Meet, Telegram, WhatsApp',
                  controller: _recruiterPlatformController,
                  prefixIcon: Icons.chat_bubble_outline_rounded,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Recruiter Messages / Interview Chat',
                  hintText: 'Paste messages or instructions received from the recruiter...',
                  controller: _recruiterMessagesController,
                  prefixIcon: Icons.message_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
              ],
            ),
            const SizedBox(height: 24),

            // Upload Attachments Panel
            const Text(
              'Attach Offer Documents / Screenshots (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            if (_selectedImageFile != null) ...[
              ImageUploadCard(
                selectedFile: _selectedImageFile,
                selectedImageBytes: _selectedImageBytes,
                onImageChanged: (file, bytes) {
                  setState(() {
                    _selectedImageFile = file;
                    _selectedImageBytes = bytes;
                  });
                },
              ),
            ] else ...[
              Row(
                children: [
                  // ── PDF / Document upload button ──────────────────────────
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickFile('pdf'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _uploadedFileType == 'pdf'
                                ? AppColors.success
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              color: _uploadedFileType == 'pdf'
                                  ? AppColors.success
                                  : AppColors.danger.withOpacity(0.8),
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _uploadedFileType == 'pdf' ? 'PDF Ready ✓' : 'Offer PDF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _uploadedFileType == 'pdf' ? AppColors.success : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Screenshot / Image upload button ─────────────────────
                  Expanded(
                    child: ImageUploadCard(
                      selectedFile: _selectedImageFile,
                      selectedImageBytes: _selectedImageBytes,
                      onImageChanged: (file, bytes) {
                        setState(() {
                          _selectedImageFile = file;
                          _selectedImageBytes = bytes;
                          // Clear document upload when image is chosen
                          if (file != null) {
                            _uploadedFileName = null;
                            _uploadedFileType = null;
                            _uploadedFileBytes = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Email / Text file upload button ───────────────────────
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickFile('email'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _uploadedFileType == 'email'
                                ? AppColors.success
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.mark_as_unread_rounded,
                              color: _uploadedFileType == 'email'
                                  ? AppColors.success
                                  : AppColors.warning,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _uploadedFileType == 'email' ? 'File Ready ✓' : 'Email Copy',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _uploadedFileType == 'email' ? AppColors.success : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Active upload preview list
            if (_uploadedFileName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _uploadedFileType == 'pdf'
                          ? Icons.picture_as_pdf_rounded
                          : (_uploadedFileType == 'image' ? Icons.image_rounded : Icons.description_rounded),
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _uploadedFileName!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      onPressed: _previewUpload,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                      onPressed: _removeUpload,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Scan Action
            CustomButton(
              text: _selectedImageFile != null ? 'Scan Image' : 'Scan with Guard AI',
              icon: Icons.security_rounded,
              onPressed: _startScan,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(child: activeBody),
    );
  }

  String _getScamTypeWithEmoji(String type) {
    switch (type) {
      case 'Advance Fee Scam':
        return '💳 Advance Fee Scam';
      case 'Fake Check / Payment Scam':
        return '🏦 Fake Check / Payment Scam';
      case 'Company or Recruiter Impersonation':
        return '🎭 Company or Recruiter Impersonation';
      case 'Messaging-App Recruitment Scam':
        return '💬 Messaging-App Recruitment Scam';
      case 'Identity / Personal Information Theft':
        return '🪪 Identity / Personal Information Theft';
      case 'Fake Work-From-Home Scam':
        return '🏡 Fake Work-From-Home Scam';
      case 'Fake Training / Certification Scam':
        return '🎓 Fake Training / Certification Scam';
      case 'Equipment Purchase Scam':
        return '💻 Equipment Purchase Scam';
      case 'Salary / Job Offer Fraud':
        return '💸 Salary / Job Offer Fraud';
      default:
        return '⚠️ Unknown / Other Suspicious Scam';
    }
  }
}
