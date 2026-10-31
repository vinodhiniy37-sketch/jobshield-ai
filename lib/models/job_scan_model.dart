enum ScanStatus { safe, lowRisk, suspicious, highRisk, scam }

class ScanIndicator {
  final String name;
  final String category;
  final String severity; // info, low, medium, high, critical
  final String description;

  ScanIndicator({
    required this.name,
    required this.category,
    required this.severity,
    required this.description,
  });

  factory ScanIndicator.fromJson(Map<String, dynamic> json) {
    return ScanIndicator(
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      severity: json['severity'] ?? 'info',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'severity': severity,
    'description': description,
  };
}

class JobScan {
  final String id;
  final String companyName;
  final String jobTitle;
  final String jobUrl;
  final String jobDescription;
  final double riskPercentage;
  final ScanStatus status;
  final String statusLabel; // 'SAFE', 'LOW RISK', 'SUSPICIOUS', 'HIGH RISK', 'SCAM'
  final List<String> reasons;
  final List<String> recommendations;
  final List<ScanIndicator> indicators;
  final DateTime scanDate;
  final String? attachmentName;
  final String? attachmentType; // 'pdf', 'image', 'doc'
  final String? salary;
  final String? location;
  final String? locationStatus;
  final double? locationConfidence;
  final String? locationSuggestion;
  final String? locationSource;
  final String? primaryScamType;
  final List<String>? scamTypes;
  final Map<String, dynamic>? recruiterDetails;

  JobScan({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.jobUrl,
    required this.jobDescription,
    required this.riskPercentage,
    required this.status,
    this.statusLabel = 'SAFE',
    required this.reasons,
    required this.recommendations,
    this.indicators = const [],
    required this.scanDate,
    this.attachmentName,
    this.attachmentType,
    this.salary,
    this.location,
    this.locationStatus,
    this.locationConfidence,
    this.locationSuggestion,
    this.locationSource,
    this.primaryScamType,
    this.scamTypes,
    this.recruiterDetails,
  });

  String get statusText {
    if (statusLabel.isNotEmpty) return statusLabel;
    switch (status) {
      case ScanStatus.safe:
        return 'SAFE';
      case ScanStatus.lowRisk:
        return 'LOW RISK';
      case ScanStatus.suspicious:
        return 'SUSPICIOUS';
      case ScanStatus.highRisk:
        return 'HIGH RISK';
      case ScanStatus.scam:
        return 'SCAM';
    }
  }

  static ScanStatus parseStatus(String? raw) {
    if (raw == null) return ScanStatus.safe;
    final lower = raw.toLowerCase().replaceAll(' ', '_');
    if (lower.contains('scam')) return ScanStatus.scam;
    if (lower.contains('high')) return ScanStatus.highRisk;
    if (lower.contains('suspicious')) return ScanStatus.suspicious;
    if (lower.contains('low')) return ScanStatus.lowRisk;
    return ScanStatus.safe;
  }

  factory JobScan.fromJson(Map<String, dynamic> json) {
    final statusStr = json['statusLabel'] ?? json['status'] ?? 'safe';
    final parsedStatus = parseStatus(statusStr.toString());

    List<ScanIndicator> indList = [];
    if (json['detectedIndicators'] != null && json['detectedIndicators'] is List) {
      indList = (json['detectedIndicators'] as List)
          .map((item) => ScanIndicator.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return JobScan(
      id: json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: json['companyName'] ?? 'Unknown Company',
      jobTitle: json['jobTitle'] ?? 'Job Scan Review',
      jobUrl: json['jobUrl'] ?? '',
      jobDescription: json['jobDescription'] ?? '',
      riskPercentage: (json['riskPercentage'] as num?)?.toDouble() ?? 5.0,
      status: parsedStatus,
      statusLabel: json['statusLabel'] ?? (parsedStatus == ScanStatus.scam ? 'SCAM' : (parsedStatus == ScanStatus.highRisk ? 'HIGH RISK' : (parsedStatus == ScanStatus.suspicious ? 'SUSPICIOUS' : (parsedStatus == ScanStatus.lowRisk ? 'LOW RISK' : 'SAFE')))),
      reasons: (json['reasons'] as List?)?.map((e) => e.toString()).toList() ?? [],
      recommendations: (json['recommendations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      indicators: indList,
      scanDate: json['scanDate'] != null ? DateTime.tryParse(json['scanDate'].toString()) ?? DateTime.now() : DateTime.now(),
      attachmentName: json['attachmentName'],
      attachmentType: json['attachmentType'],
      salary: json['salary'],
      location: json['location'],
      recruiterDetails: json['recruiterDetails'] != null ? Map<String, dynamic>.from(json['recruiterDetails']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'jobTitle': jobTitle,
    'jobUrl': jobUrl,
    'jobDescription': jobDescription,
    'riskPercentage': riskPercentage,
    'status': status.name,
    'statusLabel': statusText,
    'reasons': reasons,
    'recommendations': recommendations,
    'scanDate': scanDate.toIso8601String(),
    'attachmentName': attachmentName,
    'attachmentType': attachmentType,
    'salary': salary,
    'location': location,
  };
}
