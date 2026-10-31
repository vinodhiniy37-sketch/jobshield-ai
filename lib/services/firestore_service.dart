import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_scan_model.dart';
import '../models/scam_alert_model.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Save User profile document
  Future<void> saveUserProfile(String uid, {
    required String name,
    required String email,
    required String phone,
    String? location,
    String? profileImageUrl,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        'name': name,
        'email': email.toLowerCase(),
        'phone': phone,
        'profileImageUrl': profileImageUrl ?? '',
        'location': location ?? '',
        'securityScore': 100,
        'totalScans': 0,
        'scamsReported': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'name': name,
        'phone': phone,
        if (location != null) 'location': location,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });
    }
  }

  // Retrieve user profile data
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // Update user profile fields directly
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Save a new scan record
  Future<void> saveScan(String uid, {
    required String companyName,
    required String jobTitle,
    required String jobUrl,
    required String description,
    required double riskPercentage,
    required ScanStatus status,
    required List<String> reasons,
    required List<String> recommendations,
    String? fileUrl,
    String? imageUrl,
    String? location,
    String? locationStatus,
    double? locationConfidence,
    String? locationSuggestion,
    String? locationSource,
    String? primaryScamType,
    List<String>? scamTypes,
  }) async {
    // 1. Write the scan to the scans collection
    final scanRef = _db.collection('scans').doc();
    String statusStr = 'Safe';
    if (status == ScanStatus.suspicious) statusStr = 'Suspicious';
    if (status == ScanStatus.scam) statusStr = 'Scam';

    await scanRef.set({
      'userId': uid,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'jobUrl': jobUrl,
      'description': description,
      'imageUrl': imageUrl ?? '',
      'fileUrl': fileUrl ?? '',
      'riskPercentage': riskPercentage,
      'status': statusStr,
      'reasons': reasons,
      'recommendations': recommendations,
      'location': location ?? '',
      'locationStatus': locationStatus ?? 'not_provided',
      'locationConfidence': locationConfidence ?? 0.0,
      'locationSuggestion': locationSuggestion ?? '',
      'locationSource': locationSource ?? '',
      'primaryScamType': primaryScamType ?? '',
      'scamTypes': scamTypes ?? [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Recalculate security score for user and update profile stats
    await _updateUserScoreAndStats(uid);
  }

  // Delete a scan document by its Firestore document ID
  Future<void> deleteScan(String scanId) async {
    await _db.collection('scans').doc(scanId).delete();
  }

  // Save community scam report
  Future<void> saveReport(String uid, {
    required String companyName,
    required String jobUrl,
    required String description,
    String? evidenceUrl,
    String? proofUrl,
  }) async {
    final reportRef = _db.collection('reports').doc();
    await reportRef.set({
      'userId': uid,
      'companyName': companyName,
      'jobUrl': jobUrl,
      'description': description,
      'evidenceUrl': evidenceUrl ?? '',
      'proofUrl': proofUrl ?? '',
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update user scamsReported statistic
    final userRef = _db.collection('users').doc(uid);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (snapshot.exists) {
        int scamsReported = snapshot.data()?['scamsReported'] ?? 0;
        transaction.update(userRef, {'scamsReported': scamsReported + 1});
      }
    });
  }

  // Query scans list belonging to current user sorted by createdAt descending
  Future<List<JobScan>> getUserScans(String uid) async {
    final querySnapshot = await _db
        .collection('scans')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    final List<JobScan> scansList = [];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final statusStr = data['status']?.toString().toLowerCase() ?? 'safe';
      ScanStatus status = ScanStatus.safe;
      if (statusStr == 'suspicious') status = ScanStatus.suspicious;
      if (statusStr == 'scam') status = ScanStatus.scam;

      final Timestamp? ts = data['createdAt'] as Timestamp?;
      final DateTime date = ts != null ? ts.toDate() : DateTime.now();

      scansList.add(JobScan(
        id: doc.id,
        companyName: data['companyName'] ?? 'Unknown Employer',
        jobTitle: data['jobTitle'] ?? 'Untitled Position',
        jobUrl: data['jobUrl'] ?? '',
        jobDescription: data['description'] ?? '',
        riskPercentage: (data['riskPercentage'] as num?)?.toDouble() ?? 0.0,
        status: status,
        reasons: List<String>.from(data['reasons'] ?? []),
        recommendations: List<String>.from(data['recommendations'] ?? []),
        scanDate: date,
        attachmentName: data['fileUrl'] != '' ? 'attachment' : null,
        attachmentType: data['fileUrl'] != '' ? 'pdf' : (data['imageUrl'] != '' ? 'image' : null),
        location: data['location'] as String?,
        locationStatus: data['locationStatus'] as String?,
        locationConfidence: (data['locationConfidence'] as num?)?.toDouble(),
        locationSuggestion: data['locationSuggestion'] as String?,
        locationSource: data['locationSource'] as String?,
        primaryScamType: data['primaryScamType'] as String?,
        scamTypes: data['scamTypes'] != null ? List<String>.from(data['scamTypes']) : null,
      ));
    }
    return scansList;
  }

  // Query all reports for community alerts
  Future<List<ScamAlert>> getAllReports() async {
    final querySnapshot = await _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();

    final List<ScamAlert> alertsList = [];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final Timestamp? ts = data['createdAt'] as Timestamp?;
      final DateTime date = ts != null ? ts.toDate() : DateTime.now();

      alertsList.add(ScamAlert(
        id: doc.id,
        companyName: data['companyName'] ?? 'Unknown Employer',
        scamType: 'Job Phishing',
        description: data['description'] ?? '',
        reportedDate: date,
        reportedCount: 1,
      ));
    }
    return alertsList;
  }

  // ── CAREER PROFILE FIRESTORE SERVICES ──────────────────────────────────────
  Future<void> saveCareerProfile(String uid, Map<String, dynamic> data) async {
    final docRef = _db.collection('careerProfiles').doc(uid);
    await docRef.set({
      'userId': uid,
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getCareerProfile(String uid) async {
    return await _db.collection('careerProfiles').doc(uid).get();
  }

  // ── CAREER DOCUMENTS FIRESTORE SERVICES ────────────────────────────────────
  Future<void> saveCareerDocument(String uid, {
    required String title,
    required String category,
    required String fileUrl,
    required String fileName,
    required int fileSizeBytes,
  }) async {
    final docRef = _db.collection('careerDocuments').doc();
    await docRef.set({
      'userId': uid,
      'title': title,
      'category': category,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getUserCareerDocuments(String uid) async {
    return await _db
        .collection('careerDocuments')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> deleteCareerDocument(String docId) async {
    await _db.collection('careerDocuments').doc(docId).delete();
  }

  // Recalculates user's security score and totalScans based on actual history logs
  Future<void> _updateUserScoreAndStats(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    final scansSnapshot = await _db
        .collection('scans')
        .where('userId', isEqualTo: uid)
        .get();

    int totalScans = scansSnapshot.docs.length;
    int scamCount = 0;
    int suspiciousCount = 0;

    for (var doc in scansSnapshot.docs) {
      final statusStr = doc.data()['status']?.toString().toLowerCase() ?? 'safe';
      if (statusStr == 'scam') scamCount++;
      if (statusStr == 'suspicious') suspiciousCount++;
    }

    // Penalty calculations matching previous backend system
    int scorePenalty = (scamCount * 25) + (suspiciousCount * 12);
    int newScore = 100 - scorePenalty;
    newScore = newScore.clamp(10, 100);

    await userRef.update({
      'totalScans': totalScans,
      'securityScore': newScore,
    });
  }
}
