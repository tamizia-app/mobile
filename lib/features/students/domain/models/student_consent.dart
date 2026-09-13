class StudentConsent {
  const StudentConsent({
    required this.consentId,
    required this.studentId,
    required this.status,
    required this.consentDate,
    required this.revokedAt,
    required this.evidenceBlobPath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String consentId;
  final String studentId;
  final bool status;
  final DateTime? consentDate;
  final DateTime? revokedAt;
  final String? evidenceBlobPath;
  final DateTime createdAt;
  final DateTime updatedAt;
}
