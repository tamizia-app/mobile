import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/models/student.dart';
import '../../domain/models/student_consent.dart';
import '../../domain/repositories/student_repository.dart';
import '../viewmodels/student_detail_viewmodel.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage({required this.studentRepository, super.key});

  final StudentRepository studentRepository;

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late final StudentDetailViewModel _viewModel;
  String? _studentId;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentDetailViewModel(
      studentRepository: widget.studentRepository,
    );
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
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _editStudent() async {
    final student = _viewModel.student;
    if (student == null) {
      return;
    }
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.editStudent,
      arguments: student.studentId,
    );
    if (!mounted || updated is! Student) {
      return;
    }
    _viewModel.applyUpdate(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estudiante actualizado correctamente.')),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar estudiante?'),
        content: const Text('Esta accion eliminara al estudiante del aula.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final deleted = await _viewModel.deleteStudent();
    if (!mounted || !deleted) {
      return;
    }
    Navigator.pop(context, _viewModel.student!.studentId);
  }

  Future<void> _confirmRevokeConsent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Revocar consentimiento?'),
        content: const Text(
          'El estudiante ya no podra continuar con evaluaciones que '
          'requieran consentimiento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Revocar'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final revoked = await _viewModel.revokeConsent();
    if (!mounted || !revoked) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Consentimiento revocado.')));
  }

  Future<void> _uploadConsent() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) {
      return;
    }
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo leer el archivo.')),
        );
      }
      return;
    }
    final uploaded = await _viewModel.uploadConsent(
      bytes: bytes,
      fileName: file.name,
    );
    if (!mounted || !uploaded) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consentimiento adjuntado correctamente.')),
    );
  }

  void _goBack() {
    Navigator.pop(context, _viewModel.student);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          body: Column(
            children: [
              AppHeader(
                title: 'Detalle del estudiante',
                showBack: true,
                centerTitle: true,
                onBack: _goBack,
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final student = _viewModel.student;
    if (student == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_viewModel.errorMessage ?? 'No se pudo cargar el estudiante.'),
            TextButton(
              onPressed: _studentId == null
                  ? null
                  : () => _viewModel.loadStudent(_studentId!),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(27, 32, 27, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CircleAvatar(
            radius: 54,
            backgroundColor: Color(0xFFD5ECF7),
            child: Icon(
              Icons.person_outline,
              color: Color(0xFF44515D),
              size: 58,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student.code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF102532),
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _editStudent,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar estudiante'),
          ),
          const SizedBox(height: 22),
          _StudentDetails(student: student),
          const SizedBox(height: 24),
          _ConsentDetails(
            consent: _viewModel.consent,
            isUpdating: _viewModel.isUpdatingConsent,
            onRevoke: _confirmRevokeConsent,
            onUpload: _uploadConsent,
          ),
          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorRed),
            ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _viewModel.isDeleting ? null : _confirmDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text(
              _viewModel.isDeleting ? 'Eliminando...' : 'Eliminar estudiante',
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
          ),
        ],
      ),
    );
  }
}

class _StudentDetails extends StatelessWidget {
  const _StudentDetails({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Codigo', value: student.code),
          _DetailRow(label: 'Edad', value: '${student.age} años'),
          _DetailRow(
            label: 'Genero',
            value: student.gender == 'BOY' ? 'Niño' : 'Niña',
          ),
          _DetailRow(
            label: 'Estado',
            value: student.isActive ? 'Activo' : 'Inactivo',
          ),
          _DetailRow(label: 'Classroom ID', value: student.classroomId),
        ],
      ),
    );
  }
}

class _ConsentDetails extends StatelessWidget {
  const _ConsentDetails({
    required this.consent,
    required this.isUpdating,
    required this.onRevoke,
    required this.onUpload,
  });

  final StudentConsent? consent;
  final bool isUpdating;
  final VoidCallback onRevoke;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final current = consent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Consentimiento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: current == null
              ? const Text('Consentimiento pendiente')
              : Column(
                  children: [
                    _DetailRow(
                      label: 'Registrado',
                      value: current.status ? 'Si' : 'No',
                    ),
                    _DetailRow(
                      label: 'Fecha',
                      value: _formatDate(current.consentDate),
                    ),
                    _DetailRow(
                      label: 'Revocado',
                      value: current.revokedAt == null ? 'No' : 'Si',
                    ),
                    if (current.revokedAt != null)
                      _DetailRow(
                        label: 'Fecha revocacion',
                        value: _formatDate(current.revokedAt),
                      ),
                  ],
                ),
        ),
        if (current != null && current.status && current.revokedAt == null)
          TextButton(
            onPressed: isUpdating ? null : onRevoke,
            child: Text(
              isUpdating ? 'Procesando...' : 'Revocar consentimiento',
            ),
          ),
        if (current == null || !current.status || current.revokedAt != null)
          TextButton.icon(
            onPressed: isUpdating ? null : onUpload,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(isUpdating ? 'Subiendo...' : 'Adjuntar consentimiento'),
          ),
      ],
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return 'No disponible';
    }
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.neutralGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
