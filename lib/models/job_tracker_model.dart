enum ApplicationStatus {
  saved,
  applied,
  screening,
  interview,
  technicalRound,
  hrRound,
  selected,
  offer,
  rejected,
  withdrawn,
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.saved:
        return 'Saved';
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.screening:
        return 'Screening';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.technicalRound:
        return 'Technical Round';
      case ApplicationStatus.hrRound:
        return 'HR Round';
      case ApplicationStatus.selected:
        return 'Selected';
      case ApplicationStatus.offer:
        return 'Offer Received';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  String get code {
    switch (this) {
      case ApplicationStatus.saved:
        return 'Saved';
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.screening:
        return 'Applied';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.technicalRound:
        return 'Interview';
      case ApplicationStatus.hrRound:
        return 'Interview';
      case ApplicationStatus.selected:
        return 'Selected';
      case ApplicationStatus.offer:
        return 'Offer';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Rejected';
    }
  }

  static ApplicationStatus fromCode(String? code) {
    if (code == null) return ApplicationStatus.applied;
    final lower = code.toLowerCase().trim();
    switch (lower) {
      case 'selected':
        return ApplicationStatus.selected;
      case 'interview':
      case 'technical_round':
      case 'hr_round':
        return ApplicationStatus.interview;
      case 'rejected':
      case 'withdrawn':
        return ApplicationStatus.rejected;
      case 'offer':
        return ApplicationStatus.offer;
      case 'saved':
        return ApplicationStatus.saved;
      case 'applied':
      case 'screening':
      default:
        return ApplicationStatus.applied;
    }
  }
}

class TrackedJob {
  final String id;
  final String userId;
  final String companyName;
  final String jobTitle;
  final String jobUrl;
  final String location;
  final String employmentType; // 'Full-Time', 'Part-Time', 'Internship', 'Contract'
  final String salary;
  final String description;
  final DateTime? dateApplied;
  final DateTime? deadline;
  final DateTime? interviewDate;
  final String recruiterContact;
  final String notes;
  final ApplicationStatus status;
  final int matchScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrackedJob({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.jobTitle,
    required this.jobUrl,
    required this.location,
    required this.employmentType,
    required this.salary,
    required this.description,
    this.dateApplied,
    this.deadline,
    this.interviewDate,
    required this.recruiterContact,
    required this.notes,
    required this.status,
    required this.matchScore,
    required this.createdAt,
    required this.updatedAt,
  });

  TrackedJob copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? jobTitle,
    String? jobUrl,
    String? location,
    String? employmentType,
    String? salary,
    String? description,
    DateTime? dateApplied,
    DateTime? deadline,
    DateTime? interviewDate,
    String? recruiterContact,
    String? notes,
    ApplicationStatus? status,
    int? matchScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrackedJob(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      jobUrl: jobUrl ?? this.jobUrl,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      dateApplied: dateApplied ?? this.dateApplied,
      deadline: deadline ?? this.deadline,
      interviewDate: interviewDate ?? this.interviewDate,
      recruiterContact: recruiterContact ?? this.recruiterContact,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      matchScore: matchScore ?? this.matchScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory TrackedJob.fromJson(Map<String, dynamic> json) {
    return TrackedJob(
      id: json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['userId'] ?? '',
      companyName: json['companyName'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      jobUrl: json['jobUrl'] ?? '',
      location: json['location'] ?? '',
      employmentType: json['employmentType'] ?? 'Full-Time',
      salary: json['salary'] ?? '',
      description: json['description'] ?? '',
      dateApplied: json['dateApplied'] != null ? DateTime.tryParse(json['dateApplied'].toString()) : null,
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'].toString()) : null,
      interviewDate: json['interviewDate'] != null ? DateTime.tryParse(json['interviewDate'].toString()) : null,
      recruiterContact: json['recruiterContact'] ?? '',
      notes: json['notes'] ?? '',
      status: ApplicationStatusExtension.fromCode(json['status']),
      matchScore: (json['matchScore'] as num?)?.toInt() ?? 85,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'companyName': companyName,
    'jobTitle': jobTitle,
    'jobUrl': jobUrl,
    'location': location,
    'employmentType': employmentType,
    'salary': salary,
    'description': description,
    'dateApplied': dateApplied?.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'interviewDate': interviewDate?.toIso8601String(),
    'recruiterContact': recruiterContact,
    'notes': notes,
    'status': status.code,
    'matchScore': matchScore,
  };
}
