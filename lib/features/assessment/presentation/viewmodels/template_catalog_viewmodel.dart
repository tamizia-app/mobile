import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/assessment_template.dart';
import '../../domain/repositories/assessment_repository.dart';

class TemplateCatalogViewModel extends ChangeNotifier {
  TemplateCatalogViewModel({required AssessmentRepository assessmentRepository})
    : _assessmentRepository = assessmentRepository;

  final AssessmentRepository _assessmentRepository;

  List<AssessmentTemplate> templates = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      templates = await _assessmentRepository.getTemplates();
    } catch (error) {
      errorMessage = error is ApiException
          ? error.message
          : 'No se pudieron cargar las plantillas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
