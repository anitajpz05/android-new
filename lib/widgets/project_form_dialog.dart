import 'package:flutter/material.dart';

import '../models/project.dart';
import '../state/app_store.dart';

/// Diálogo para crear un proyecto (project == null) o editar uno existente.
Future<void> showProjectFormDialog(
  BuildContext context, {
  required AppStore store,
  Project? project,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ProjectFormDialog(store: store, project: project),
  );
}

class _ProjectFormDialog extends StatefulWidget {
  const _ProjectFormDialog({required this.store, this.project});

  final AppStore store;
  final Project? project;

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.project?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final project = widget.project;
    if (project == null) {
      widget.store.addProject(
        name: _nameController.text,
        description: _descriptionController.text,
      );
    } else {
      widget.store.updateProject(
        project.id,
        name: _nameController.text,
        description: _descriptionController.text,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.project == null;

    return AlertDialog(
      title: Text(isNew ? 'Nuevo proyecto' : 'Editar proyecto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción corta',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
