import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../classrooms/domain/models/classroom.dart';
import '../../../classrooms/domain/repositories/classroom_repository.dart';
import '../../../students/domain/models/student.dart';
import '../../../students/domain/models/student_consent.dart';
import '../../../students/domain/repositories/student_repository.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/assessment_attempt.dart';
import '../../domain/models/assessment_attempt_preview.dart';
import '../../domain/models/assessment_template.dart';
import '../../domain/repositories/assessment_repository.dart';

class AssessmentConfigViewModel extends ChangeNotifier {
  AssessmentConfigViewModel({
    required ClassroomRepository classroomRepository,
    required StudentRepository studentRepository,
    required AssessmentRepository assessmentRepository,
  }) : _classroomRepository = classroomRepository,
       _studentRepository = studentRepository,
       _assessmentRepository = assessmentRepository;

  final ClassroomRepository _classroomRepository;
  final StudentRepository _studentRepository;
  final AssessmentRepository _assessmentRepository;

  List<Classroom> classrooms = const [];
  List<Student> students = const [];
  List<AssessmentTemplate> templates = const [];
  String classroomId = '';
  String studentId = '';
  String templateId = '';
  bool isLoading = false;
  bool isSubmitting = false;
  bool isLoadingConsent = false;
  bool missingConsent = false;
  String? errorMessage;
  StudentConsent? consent;
  AssessmentAttempt? pendingAttempt;

  Classroom? get selectedClassroom =>
      _findById(classrooms, classroomId, (item) => item.id);

  Student? get selectedStudent =>
      _findById(students, studentId, (item) => item.id);

  AssessmentTemplate? get selectedTemplate =>
      _findById(templates, templateId, (item) => item.id);

  bool get hasValidConsent =>
      consent?.status == true && consent?.revokedAt == null;

  Future<void> load({String? preselectedTemplateId}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final responses = await Future.wait([
        _classroomRepository.getClassrooms(),
        _assessmentRepository.getTemplates(),
      ]);
      classrooms = responses[0] as List<Classroom>;
      templates = responses[1] as List<AssessmentTemplate>;
      if (preselectedTemplateId != null && preselectedTemplateId.isNotEmpty) {
        templateId = preselectedTemplateId;
      }
      if (classrooms.isNotEmpty) {
        classroomId = classrooms.first.id;
        students = await _studentRepository.getStudentsByClassroom(classroomId);
      }
    } catch (error) {
      errorMessage = _messageFor(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setClassroom(String value) async {
    classroomId = value;
    studentId = '';
    consent = null;
    missingConsent = false;
    pendingAttempt = null;
    notifyListeners();
    try {
      students = await _studentRepository.getStudentsByClassroom(value);
      errorMessage = null;
    } catch (error) {
      students = const [];
      errorMessage = _messageFor(error);
    }
    notifyListeners();
  }

  Future<void> setStudent(String value) async {
    studentId = value;
    consent = null;
    missingConsent = false;
    pendingAttempt = null;
    isLoadingConsent = true;
    notifyListeners();
    try {
      consent = await _studentRepository.getConsent(value);
      missingConsent = !hasValidConsent;
      errorMessage = null;
    } catch (error) {
      errorMessage = _messageFor(error);
    } finally {
      isLoadingConsent = false;
      notifyListeners();
    }
  }

  void setTemplate(String value) {
    templateId = value;
    pendingAttempt = null;
    notifyListeners();
  }

  bool validate() {
    errorMessage =
        AuthValidators.validateRequiredField(
          classroomId,
          'Selecciona un aula.',
        ) ??
        AuthValidators.validateRequiredField(
          studentId,
          'Selecciona un estudiante.',
        ) ??
        AuthValidators.validateRequiredField(
          templateId,
          'Selecciona una plantilla.',
        );
    if (errorMessage == null && !hasValidConsent) {
      missingConsent = true;
      errorMessage = 'No se puede iniciar sin un consentimiento válido.';
    }
    notifyListeners();
    return errorMessage == null;
  }

  Future<AssessmentAttemptPreview?> createAssessmentAndAttempt() async {
    if (!validate()) {
      return null;
    }
    final classroom = selectedClassroom;
    final student = selectedStudent;
    final selectedTemplateValue = selectedTemplate;
    if (classroom == null || student == null || selectedTemplateValue == null) {
      errorMessage = 'No se pudo preparar la evaluación.';
      notifyListeners();
      return null;
    }

    isSubmitting = true;
    missingConsent = false;
    pendingAttempt = null;
    errorMessage = null;
    notifyListeners();
    try {
      final template = await _loadTemplateDetails(selectedTemplateValue);
      final assessment = await _assessmentRepository.createAssessment(
        classroomId: classroomId,
        templateId: templateId,
      );
      final existingAttempt = await _findExistingIncompleteAttempt(
        assessment,
        studentId,
      );
      if (existingAttempt != null) {
        pendingAttempt = existingAttempt;
        return AssessmentAttemptPreview(
          classroom: classroom,
          student: student,
          template: template,
          assessment: assessment,
          attempt: existingAttempt,
          hasValidConsent: true,
          resumedExistingAttempt: true,
        );
      }
      final attempt = await _assessmentRepository.startAttempt(
        assessmentId: assessment.id,
        studentId: studentId,
      );
      return AssessmentAttemptPreview(
        classroom: classroom,
        student: student,
        template: template,
        assessment: assessment,
        attempt: attempt,
        hasValidConsent: true,
      );
    } catch (error) {
      final message = _messageFor(error);
      if (_looksLikeConsentError(message)) {
        missingConsent = true;
        errorMessage = 'No se puede iniciar sin un consentimiento válido.';
      } else {
        errorMessage = message;
      }
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<AssessmentTemplate> _loadTemplateDetails(
    AssessmentTemplate template,
  ) async {
    final hasCompleteExerciseTitles =
        template.exercises.isNotEmpty &&
        template.exercises.every(
          (exercise) => exercise.title?.trim().isNotEmpty == true,
        );
    if (hasCompleteExerciseTitles) {
      return template;
    }
    try {
      return await _assessmentRepository.getTemplateById(template.id);
    } catch (_) {
      return template;
    }
  }

  Future<AssessmentAttempt?> _findExistingIncompleteAttempt(
    Assessment assessment,
    String studentId,
  ) async {
    final attempts = await _assessmentRepository.getAttempts(assessment.id);
    for (final attempt in attempts) {
      if (attempt.studentId == studentId && attempt.isIncomplete) {
        return attempt;
      }
    }
    return null;
  }

  T? _findById<T>(List<T> items, String id, String Function(T item) getId) {
    if (id.isEmpty) {
      return null;
    }
    for (final item in items) {
      if (getId(item) == id) {
        return item;
      }
    }
    return null;
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo completar la solicitud.';
  }

  bool _looksLikeConsentError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('consent') ||
        normalized.contains('consentimiento') ||
        normalized.contains('autorizacion');
  }
}
