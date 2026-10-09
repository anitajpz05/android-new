import 'package:flutter/material.dart';

import '../models/project.dart';
import '../state/app_scope.dart';
import '../utils/navigation.dart';
import '../widgets/empty_message.dart';
import '../widgets/note_tile.dart';
import '../widgets/tag_filter_bar.dart';
import 'note_detail_screen.dart';

/// RF6. Búsqueda global en todas las notas, con filtros opcionales por
/// proyecto y por etiquetas.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _projectId;
  final Set<String> _tagIds = {};
  bool _matchAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTag(String id) {
    setState(() {
      if (!_tagIds.remove(id)) _tagIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final projects = store.projects;
    final tags = store.tags;

    // Descarta filtros de proyecto o etiqueta que ya no existen.
    final projectId = projects.any((p) => p.id == _projectId) ? _projectId : null;
    final activeTagIds = _tagIds.where((id) => store.tagById(id) != null).toSet();

    final results = store.searchNotes(
      query: _searchController.text,
      projectId: projectId,
      tagIds: activeTagIds,
      matchAll: _matchAll,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Título o contenido de todas las notas',
                prefixIcon: Icon(Icons.manage_search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              // Margen superior: sin él se recorta la etiqueta del desplegable.
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Proyecto',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: projectId,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todos los proyectos'),
                          ),
                          for (final Project project in projects)
                            DropdownMenuItem<String?>(
                              value: project.id,
                              child: Text(
                                project.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) => setState(() => _projectId = value),
                      ),
                    ),
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TagFilterBar(
                      tags: tags,
                      selectedIds: activeTagIds,
                      onToggle: _toggleTag,
                      matchAll: _matchAll,
                      onModeChanged: (value) => setState(() => _matchAll = value),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: results.isEmpty
                ? const EmptyMessage(
                    icon: Icons.find_in_page_outlined,
                    message: 'No hay notas que coincidan con la búsqueda.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: results.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final note = results[index];
                      return NoteTile(
                        note: note,
                        projectName: store.projectById(note.projectId)?.name,
                        onTap: () => pushScreen(
                          context,
                          NoteDetailScreen(noteId: note.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
