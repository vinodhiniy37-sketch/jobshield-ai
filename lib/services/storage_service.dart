import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  // Upload profile photo bytes to users/{userId}/profile/profile.jpg
  Future<String> uploadProfileImage(String uid, Uint8List fileBytes, String fileName) async {
    try {
      final ext = fileName.split('.').last;
      final ref = _storage.ref().child('users/$uid/profile/profile.$ext');
      
      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: _getContentType(ext)),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Upload scan attachment bytes to users/{userId}/scans/{fileName}
  Future<String> uploadScanAttachment(String uid, Uint8List fileBytes, String fileName) async {
    try {
      final ext = fileName.split('.').last;
      final ref = _storage.ref().child('users/$uid/scans/$fileName');
      
      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: _getContentType(ext)),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload scan document: $e');
    }
  }

  // Upload report evidence bytes to users/{userId}/reports/{fileName}
  Future<String> uploadReportEvidence(String uid, Uint8List fileBytes, String fileName) async {
    try {
      final ext = fileName.split('.').last;
      final ref = _storage.ref().child('users/$uid/reports/$fileName');
      
      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: _getContentType(ext)),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload report evidence: $e');
    }
  }

  // Get MIME type helper
  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }
}
