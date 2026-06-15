import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/services/classroom_service.dart';
import '../viewmodels/classroom_form_viewmodel.dart';
import 'create_classroom_page.dart';

class EditClassroomPage extends StatefulWidget {
  const EditClassroomPage({required this.classroomService, super.key});

  final ClassroomService classroomService;

  @override
  State<EditClassroomPage> createState() => _EditClassroomPageState();
}

class _EditClassroomPageState extends State<EditClassroomPage> {
  late final ClassroomFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _classroomId = 'classroom-3b';

  @override
  void initState() {
    super.initState();
    _viewModel = ClassroomFormViewModel(
      classroomService: widget.classroomService,
    )..addListener(_syncName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String && argument != _classroomId) {
      _classroomId = argument;
    }
    if (_viewModel.id.isEmpty) {
      _viewModel.loadClassroom(_classroomId);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncName);
    _nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _syncName() {
    if (_nameController.text == _viewModel.name) return;
    _nameController.text = _viewModel.name;
    _nameController.selection = TextSelection.collapsed(
      offset: _viewModel.name.length,
    );
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    final saved = await _viewModel.update();
    if (!mounted || !formValid || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aula actualizada correctamente')),
    );
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.classroomDetail,
      arguments: _classroomId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClassroomFormScaffold(
      title: 'Editar aula',
      buttonText: 'Guardar',
      formKey: _formKey,
      viewModel: _viewModel,
      nameController: _nameController,
      onCancel: () => Navigator.pushReplacementNamed(
        context,
        AppRoutes.classroomDetail,
        arguments: _classroomId,
      ),
      onSave: _save,
    );
  }
}
