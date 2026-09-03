import 'package:flutter/material.dart';

import '../../domain/repositories/student_repository.dart';
import '../viewmodels/student_form_viewmodel.dart';
import 'create_student_page.dart';

class EditStudentPage extends StatefulWidget {
  const EditStudentPage({required this.studentRepository, super.key});

  final StudentRepository studentRepository;

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  late final StudentFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _ageController = TextEditingController();
  String? _studentId;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentFormViewModel(
      studentRepository: widget.studentRepository,
    );
    _viewModel.addListener(_syncControllers);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String && argument.isNotEmpty) {
      _studentId = argument;
    }
    if (!_requestedLoad && _studentId != null) {
      _requestedLoad = true;
      _viewModel.loadStudent(_studentId!);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncControllers);
    _codeController.dispose();
    _ageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _syncControllers() {
    _setText(_codeController, _viewModel.code);
    _setText(_ageController, _viewModel.age);
  }

  void _setText(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: value.length);
  }

  Future<void> _save() async {
    if (!_viewModel.canSave || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final updated = await _viewModel.updateStudent();
    if (!mounted || updated == null) {
      return;
    }
    Navigator.pop(context, updated);
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    _viewModel.resetForm();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final studentId = _studentId;
    if (studentId == null) {
      return const Scaffold(
        body: Center(child: Text('No se pudo identificar el estudiante.')),
      );
    }
    return StudentFormScaffold(
      title: 'Editar estudiante',
      buttonText: 'Guardar cambios',
      formKey: _formKey,
      viewModel: _viewModel,
      codeController: _codeController,
      ageController: _ageController,
      onCancel: _cancel,
      onSave: _save,
      onRetry: () => _viewModel.loadStudent(studentId),
    );
  }
}
