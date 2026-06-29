import 'package:flutter/material.dart';

import '../../domain/repositories/classroom_repository.dart';
import '../viewmodels/classroom_form_viewmodel.dart';
import 'create_classroom_page.dart';

class EditClassroomPage extends StatefulWidget {
  const EditClassroomPage({required this.classroomRepository, super.key});

  final ClassroomRepository classroomRepository;

  @override
  State<EditClassroomPage> createState() => _EditClassroomPageState();
}

class _EditClassroomPageState extends State<EditClassroomPage> {
  late final ClassroomFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _classroomId;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ClassroomFormViewModel(
      classroomRepository: widget.classroomRepository,
    );
    _viewModel.addListener(_syncName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String && argument.isNotEmpty) {
      _classroomId = argument;
    }
    if (!_requestedLoad && _classroomId != null) {
      _requestedLoad = true;
      _viewModel.loadClassroom(_classroomId!);
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
    if (_nameController.text == _viewModel.name) {
      return;
    }
    _nameController.text = _viewModel.name;
    _nameController.selection = TextSelection.collapsed(
      offset: _viewModel.name.length,
    );
  }

  Future<void> _save() async {
    if (!_viewModel.canSave || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final updated = await _viewModel.update();
    if (!mounted || updated == null) {
      return;
    }
    Navigator.pop(context, updated);
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    _viewModel.restore();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final classroomId = _classroomId;
    if (classroomId == null) {
      return const Scaffold(
        body: Center(child: Text('No se pudo identificar el aula.')),
      );
    }
    return ClassroomFormScaffold(
      title: 'Editar aula',
      buttonText: 'Guardar cambios',
      formKey: _formKey,
      viewModel: _viewModel,
      nameController: _nameController,
      onCancel: _cancel,
      onSave: _save,
      onRetry: () => _viewModel.loadClassroom(classroomId),
    );
  }
}
