import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/services/student_service.dart';
import '../viewmodels/student_form_viewmodel.dart';
import 'create_student_page.dart';

class EditStudentPage extends StatefulWidget {
  const EditStudentPage({required this.studentService, super.key});

  final StudentService studentService;

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  late final StudentFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _ageController = TextEditingController();
  String _studentId = 'student-detail';

  @override
  void initState() {
    super.initState();
    _viewModel = StudentFormViewModel(studentService: widget.studentService)
      ..addListener(_syncControllers);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) {
      _studentId = argument;
    }
    if (_viewModel.id.isEmpty) {
      _viewModel.loadStudent(_studentId);
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
    if (controller.text == value) return;
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: value.length);
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    final saved = await _viewModel.update();
    if (!mounted || !formValid || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estudiante actualizado correctamente')),
    );
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.studentDetail,
      arguments: _studentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StudentFormScaffold(
      title: 'Editar estudiante',
      buttonText: 'Guardar cambios',
      formKey: _formKey,
      viewModel: _viewModel,
      codeController: _codeController,
      ageController: _ageController,
      onCancel: () => Navigator.pushReplacementNamed(
        context,
        AppRoutes.studentDetail,
        arguments: _studentId,
      ),
      onSave: _save,
    );
  }
}
