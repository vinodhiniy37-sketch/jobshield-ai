class ScamAlert {
  final String id;
  final String companyName;
  final String scamType;
  final String description;
  final DateTime reportedDate;
  final int reportedCount;

  ScamAlert({
    required this.id,
    required this.companyName,
    required this.scamType,
    required this.description,
    required this.reportedDate,
    required this.reportedCount,
  });
}
