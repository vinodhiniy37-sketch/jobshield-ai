class CareerDocument {
  final String id;
  final String userId;
  final String title;
  final String category; // 'Resume', 'Cover Letter', 'Certificate', 'Portfolio', 'Other'
  final String fileUrl;
  final String fileName;
  final int fileSizeBytes;
  final DateTime uploadDate;
  final String content;

  CareerDocument({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.fileUrl,
    required this.fileName,
    required this.fileSizeBytes,
    required this.uploadDate,
    this.content = '',
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
