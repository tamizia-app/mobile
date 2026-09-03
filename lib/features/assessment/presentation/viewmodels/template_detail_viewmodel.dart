import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/assessment_template.dart';
import '../../domain/repositories/assessment_repository.dart';

class TemplateDetailViewModel extends ChangeNotifier {
  TemplateDetailViewModel({required AssessmentRepository assessmentRepository})
    : _assessmentRepository = assessmentRepository;

  final AssessmentRepository _assessmentRepository;

  AssessmentTemplate? template;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load(String templateId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      template = await _assessmentRepository.getTemplateById(templateId);
    } catch (error) {
      errorMessage = error is ApiException
          ? error.message
          : 'No se pudo cargar la plantilla.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
