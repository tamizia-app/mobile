import '../../domain/models/student_consent.dart';

class StudentConsentDto {
  const StudentConsentDto({
    required this.consentId,
    required this.studentId,
    required this.status,
    required this.consentDate,
    required this.revokedAt,
    required this.evidenceBlobPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentConsentDto.fromJson(Map<String, dynamic> json) {
    return StudentConsentDto(
      consentId: _requiredString(json, 'consent_id'),
      studentId: _requiredString(json, 'student_id'),
      status: json['status'] as bool,
      consentDate: _nullableDateTime(json, 'consent_date'),
      revokedAt: _nullableDateTime(json, 'revoked_at'),
      evidenceBlobPath: json['evidence_blob_path'] as String?,
      createdAt: _requiredDateTime(json, 'created_at'),
      updatedAt: _requiredDateTime(json, 'updated_at'),
    );
  }

  final String consentId;
  final String studentId;
  final bool status;
  final DateTime? consentDate;
  final DateTime? revokedAt;
  final String? evidenceBlobPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentConsent toDomain() {
    return StudentConsent(
      consentId: consentId,
      studentId: studentId,
      status: status,
      consentDate: consentDate,
      revokedAt: revokedAt,
      evidenceBlobPath: evidenceBlobPath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Invalid consent field: $key.');
    }
    return value;
  }

  static DateTime _requiredDateTime(Map<String, dynamic> json, String key) {
    final parsed = _nullableDateTime(json, key);
    if (parsed == null) {
      throw FormatException('Invalid consent field: $key.');
    }
    return parsed;
  }

  static DateTime? _nullableDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw FormatException('Invalid consent field: $key.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException('Invalid consent field: $key.');
    }
    return parsed;
  }
}
