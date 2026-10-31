import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/career_document_model.dart';
import '../../widgets/empty_state.dart';

class CareerDocumentsScreen extends StatefulWidget {
  const CareerDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<CareerDocumentsScreen> createState() => _CareerDocumentsScreenState();
}

class _CareerDocumentsScreenState extends State<CareerDocumentsScreen> {
  String _selectedCategoryFilter = 'All';

  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final service = Provider.of<MockDataService>(context, listen: false);

        String category = 'Resume';
        final nameLower = file.name.toLowerCase();
        if (nameLower.contains('cover')) category = 'Cover Letter';
        if (nameLower.contains('cert')) category = 'Certificate';
        if (nameLower.contains('portfolio')) category = 'Portfolio';

        final newDoc = CareerDocument(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: service.careerProfile.userId,
          title: file.name,
          category: category,
          fileUrl: '',
          fileName: file.name,
          fileSizeBytes: file.size,
          uploadDate: DateTime.now(),
        );

        service.addCareerDocument(newDoc);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document "${file.name}" uploaded successfully!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload cancelled or note: $e'), backgroundColor: AppColors.warning),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    final docs = service.careerDocuments;
    final filtered = _selectedCategoryFilter == 'All'
        ? docs
        : docs.where((d) => d.category == _selectedCategoryFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Documents Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded, color: AppColors.primary),
            onPressed: _uploadDocument,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Chips
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All Files', 'All', isDark),
                  _buildCategoryChip('Resumes', 'Resume', isDark),
                  _buildCategoryChip('Cover Letters', 'Cover Letter', isDark),
                  _buildCategoryChip('Certificates', 'Certificate', isDark),
                  _buildCategoryChip('Portfolio', 'Portfolio', isDark),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Document List
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      title: 'No Documents Uploaded',
                      description: 'Store resumes, cover letters, and certificates in your document vault.',
                      icon: Icons.folder_open_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            if (doc.content.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(doc.title),
                                  content: SingleChildScrollView(
                                    child: Text(doc.content, style: const TextStyle(fontSize: 13, height: 1.5)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Preview not available for uploaded files')),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(doc.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('${doc.category} • ${doc.formattedSize}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                                  onPressed: () => service.deleteCareerDocument(doc.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload Document'),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value, bool isDark) {
    final isSelected = _selectedCategoryFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black))),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategoryFilter = value),
        selectedColor: AppColors.primary,
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        side: BorderSide(color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
    );
  }
}
