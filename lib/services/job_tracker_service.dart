import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_tracker_model.dart';

class JobTrackerService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Save new tracked job application
  Future<void> saveJob(String uid, TrackedJob job) async {
    final docRef = _db.collection('jobTracker').doc(job.id);
    await docRef.set({
      'userId': uid,
      'companyName': job.companyName,
      'jobTitle': job.jobTitle,
      'jobUrl': job.jobUrl,
      'location': job.location,
      'employmentType': job.employmentType,
      'salary': job.salary,
      'description': job.description,
      'dateApplied': job.dateApplied != null ? Timestamp.fromDate(job.dateApplied!) : null,
      'deadline': job.deadline != null ? Timestamp.fromDate(job.deadline!) : null,
      'interviewDate': job.interviewDate != null ? Timestamp.fromDate(job.interviewDate!) : null,
      'recruiterContact': job.recruiterContact,
      'notes': job.notes,
      'status': job.status.code,
      'matchScore': job.matchScore,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update existing job status or notes
  Future<void> updateJob(String uid, TrackedJob job) async {
    final docRef = _db.collection('jobTracker').doc(job.id);
    await docRef.update({
      'companyName': job.companyName,
      'jobTitle': job.jobTitle,
      'jobUrl': job.jobUrl,
      'location': job.location,
      'employmentType': job.employmentType,
      'salary': job.salary,
      'description': job.description,
      'dateApplied': job.dateApplied != null ? Timestamp.fromDate(job.dateApplied!) : null,
      'deadline': job.deadline != null ? Timestamp.fromDate(job.deadline!) : null,
      'interviewDate': job.interviewDate != null ? Timestamp.fromDate(job.interviewDate!) : null,
      'recruiterContact': job.recruiterContact,
      'notes': job.notes,
      'status': job.status.code,
      'matchScore': job.matchScore,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update status only (Kanban drag-and-drop / stage update)
  Future<void> updateJobStatus(String jobId, ApplicationStatus newStatus) async {
    final docRef = _db.collection('jobTracker').doc(jobId);
    await docRef.update({
      'status': newStatus.code,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete tracked job
  Future<void> deleteJob(String jobId) async {
    await _db.collection('jobTracker').doc(jobId).delete();
  }

  // Fetch all tracked jobs belonging to authenticated user UID
  Future<List<TrackedJob>> getUserJobs(String uid) async {
    final snapshot = await _db
        .collection('jobTracker')
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .get();

    final List<TrackedJob> jobs = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? appliedTs = data['dateApplied'] as Timestamp?;
      final Timestamp? deadlineTs = data['deadline'] as Timestamp?;
      final Timestamp? interviewTs = data['interviewDate'] as Timestamp?;
      final Timestamp? createdTs = data['createdAt'] as Timestamp?;
      final Timestamp? updatedTs = data['updatedAt'] as Timestamp?;

      jobs.add(TrackedJob(
        id: doc.id,
        userId: data['userId'] ?? uid,
        companyName: data['companyName'] ?? '',
        jobTitle: data['jobTitle'] ?? '',
        jobUrl: data['jobUrl'] ?? '',
        location: data['location'] ?? '',
        employmentType: data['employmentType'] ?? 'Full-Time',
        salary: data['salary'] ?? '',
        description: data['description'] ?? '',
        dateApplied: appliedTs?.toDate(),
        deadline: deadlineTs?.toDate(),
        interviewDate: interviewTs?.toDate(),
        recruiterContact: data['recruiterContact'] ?? '',
        notes: data['notes'] ?? '',
        status: ApplicationStatusExtension.fromCode(data['status'] ?? 'saved'),
        matchScore: (data['matchScore'] as num?)?.toInt() ?? 80,
        createdAt: createdTs?.toDate() ?? DateTime.now(),
        updatedAt: updatedTs?.toDate() ?? DateTime.now(),
      ));
    }
    return jobs;
  }
}
