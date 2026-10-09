import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/tag.dart';
import '../state/app_scope.dart';
import '../utils/navigation.dart';
import '../utils/text_utils.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_message.dart';
import '../widgets/tag_chips.dart';
import 'note_editor_screen.dart';
import 'tags_screen.dart';

/// RF4. Detalle de una nota. Desde aquí se llega al editor y a Etiquetas.
class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final note = store.noteById(noteId);
    if (note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyMessage(
          icon: Icons.sticky_note_2_outlined,
          message: 'Esta nota ya no existe.',
        ),
      );
    }

    final project = store.projectById(note.projectId);
    final tags = note.tagIds.map(store.tagById).whereType<Tag>().toList();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de nota')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.library_books_outlined,
                text: project?.name ?? 'Proyecto eliminado',
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: 'Creada: ${formatDate(note.createdAt)}',
              ),
              _InfoRow(
                icon: Icons.update,
                text: 'Última modificación: ${formatDate(note.updatedAt)}',
              ),
              const SizedBox(height: 16),
              Text('Etiquetas', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TagChips(
                tags: tags,
                emptyText: 'Esta nota no tiene etiquetas.',
                onTap: (tag) => pushScreen(
                  context,
                  TagsScreen(initialTagId: tag.id),
                ),
              ),
              const SizedBox(height: 16),
              Text('Descripción', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              // Área con scroll propio para textos largos.
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 360),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: note.description.isEmpty
                    ? Text(
                        'Sin descripción.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: colors.outline,
                        ),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          note.description,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Editar'),
                    onPressed: () => pushScreen(
                      context,
                      NoteEditorScreen(
                        projectId: note.projectId,
                        noteId: note.id,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                    ),
                    onPressed: () => _delete(context, note),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Note note) async {
    final confirmed = await confirmAction(
      context,
      title: '¿Eliminar nota?',
      message: '"${note.title}" se eliminará definitivamente.',
    );
    if (!confirmed || !context.mounted) return;

    final store = AppScope.read(context);
    Navigator.of(context).pop();
    store.deleteNote(note.id);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
