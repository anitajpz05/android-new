import 'package:flutter/material.dart';

import '../models/note.dart';
import '../state/app_scope.dart';
import '../utils/navigation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_message.dart';
import '../widgets/note_tile.dart';
import '../widgets/tag_filter_bar.dart';
import 'note_detail_screen.dart';
import 'note_editor_screen.dart';

/// RF2. Notas de un proyecto con búsqueda, filtro por etiquetas y creación.
class ProjectNotesScreen extends StatefulWidget {
  const ProjectNotesScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectNotesScreen> createState() => _ProjectNotesScreenState();
}

class _ProjectNotesScreenState extends State<ProjectNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTagIds = {};
  bool _matchAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTag(String id) {
    setState(() {
      if (!_selectedTagIds.remove(id)) _selectedTagIds.add(id);
    });
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await confirmAction(
      context,
      title: '¿Eliminar nota?',
      message: '"${note.title}" se eliminará definitivamente.',
    );
    if (confirmed && mounted) {
      AppScope.read(context).deleteNote(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final project = store.projectById(widget.projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyMessage(
          icon: Icons.bookmark_remove_outlined,
          message: 'Este proyecto ya no existe.',
        ),
      );
    }

    final total = store.noteCount(project.id);
    final projectTags = store.tagsInProject(project.id);
    // Descarta filtros de etiquetas que ya no están en este proyecto.
    final activeTagIds = _selectedTagIds
        .where((id) => projectTags.any((tag) => tag.id == id))
        .toSet();
    final notes = store.searchNotes(
      query: _searchController.text,
      projectId: project.id,
      tagIds: activeTagIds,
      matchAll: _matchAll,
    );

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total ${total == 1 ? 'nota' : 'notas'} en el proyecto',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o contenido',
                    prefixIcon: const Icon(Icons.manage_search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                if (projectTags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TagFilterBar(
                    tags: projectTags,
                    selectedIds: activeTagIds,
                    onToggle: _toggleTag,
                    matchAll: _matchAll,
                    onModeChanged: (value) => setState(() => _matchAll = value),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: notes.isEmpty
                ? EmptyMessage(
                    icon: Icons.sticky_note_2_outlined,
                    message: total == 0
                        ? 'Este proyecto todavía no tiene notas.\n'
                            'Pulsa "Nueva nota" para crear la primera.'
                        : 'Ninguna nota coincide con la búsqueda o los filtros.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteTile(
                        note: note,
                        onTap: () => pushScreen(
                          context,
                          NoteDetailScreen(noteId: note.id),
                        ),
                        trailing: IconButton(
                          tooltip: 'Eliminar nota',
                          icon: const Icon(Icons.delete_sweep_outlined),
                          onPressed: () => _deleteNote(note),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        icon: const Icon(Icons.add),
        label: const Text('Nueva nota'),
        onPressed: () => pushScreen(
          context,
          NoteEditorScreen(projectId: project.id),
        ),
      ),
    );
  }
}
