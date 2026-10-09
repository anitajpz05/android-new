import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/tag.dart';
import '../state/app_scope.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/tag_autocomplete_field.dart';
import '../widgets/tag_chips.dart';

/// RF3. Editor para crear (noteId == null) o editar una nota.
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, required this.projectId, this.noteId});

  final String projectId;
  final String? noteId;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final List<String> _tagIds;

  // Valores de partida, para saber si hay cambios sin guardar.
  late final String _initialTitle;
  late final String _initialDescription;
  late final List<String> _initialTagIds;

  @override
  void initState() {
    super.initState();
    final noteId = widget.noteId;
    final note = noteId == null ? null : AppScope.read(context).noteById(noteId);

    _titleController = TextEditingController(text: note?.title ?? '');
    _descriptionController = TextEditingController(text: note?.description ?? '');
    _tagIds = List.of(note?.tagIds ?? const <String>[]);

    _initialTitle = _titleController.text;
    _initialDescription = _descriptionController.text;
    _initialTagIds = List.of(_tagIds);

    _titleController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _hasChanges =>
      _titleController.text != _initialTitle ||
      _descriptionController.text != _initialDescription ||
      !listEquals(_tagIds, _initialTagIds);

  void _addTag(Tag tag) {
    if (_tagIds.contains(tag.id)) return;
    setState(() => _tagIds.add(tag.id));
  }

  void _removeTag(Tag tag) => setState(() => _tagIds.remove(tag.id));

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    AppScope.read(context).saveNote(
      id: widget.noteId,
      projectId: widget.projectId,
      title: _titleController.text,
      description: _descriptionController.text,
      tagIds: _tagIds,
    );
    Navigator.of(context).pop();
  }

  Future<void> _requestExit() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await confirmAction(
      context,
      title: 'Cambios sin guardar',
      message: 'Tienes cambios sin guardar. ¿Quieres salir y descartarlos?',
      confirmLabel: 'Descartar',
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final assignedTags =
        _tagIds.map(store.tagById).whereType<Tag>().toList();
    final isNew = widget.noteId == null;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isNew ? 'Nueva nota' : 'Editar nota'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'El título es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    // Con maxLines fijo, el campo tiene scroll interno y no desborda.
                    minLines: 8,
                    maxLines: 14,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Etiquetas',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TagChips(
                    tags: assignedTags,
                    onDeleted: _removeTag,
                    emptyText: 'Esta nota todavía no tiene etiquetas.',
                  ),
                  const SizedBox(height: 12),
                  TagAutocompleteField(
                    assignedIds: _tagIds.toSet(),
                    onTagSelected: _addTag,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _requestExit,
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
