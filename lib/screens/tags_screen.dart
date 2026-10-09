import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/tag.dart';
import '../state/app_scope.dart';
import '../utils/navigation.dart';
import '../utils/text_utils.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_message.dart';
import '../widgets/note_tile.dart';
import '../widgets/tag_filter_bar.dart';
import '../widgets/tag_name_dialog.dart';
import 'note_detail_screen.dart';

enum _TagAction { rename, delete }

/// RF5. Gestión de etiquetas y agrupación de notas de todos los proyectos.
///
/// Se usa como pestaña y también desde el detalle de nota, con
/// [initialTagId] para abrirla ya filtrada por una etiqueta.
class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key, this.initialTagId});

  final String? initialTagId;

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTagIds = {};
  bool _matchAll = false;

  @override
  void initState() {
    super.initState();
    final initialId = widget.initialTagId;
    if (initialId != null) _selectedTagIds.add(initialId);
  }

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

  Future<void> _createTag() async {
    final store = AppScope.read(context);
    final name = await showTagNameDialog(context, store: store);
    if (name == null || !mounted) return;

    final created = store.createTag(name);
    if (created == null) _showError('Ya existe una etiqueta con ese nombre.');
  }

  Future<void> _renameTag(Tag tag) async {
    final store = AppScope.read(context);
    final name = await showTagNameDialog(context, store: store, tag: tag);
    if (name == null || !mounted) return;

    if (!store.renameTag(tag.id, name)) {
      _showError('Ya existe una etiqueta con ese nombre.');
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    final store = AppScope.read(context);
    final usage = store.tagUsage(tag.id);
    final confirmed = await confirmAction(
      context,
      title: '¿Eliminar etiqueta "${tag.name}"?',
      message: usage == 0
          ? 'Esta etiqueta no se usa en ninguna nota.'
          : 'Se quitará de $usage ${usage == 1 ? 'nota' : 'notas'}. '
              'Las notas no se borrarán.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _selectedTagIds.remove(tag.id));
    store.deleteTag(tag.id);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final allTags = store.tags;
    final query = _searchController.text;
    final key = normalizeText(query);
    final visibleTags = allTags
        .where((tag) => normalizeText(tag.name).contains(key))
        .toList();
    final selected = _selectedTagIds
        .where((id) => store.tagById(id) != null)
        .toSet();
    final notes = selected.isEmpty
        ? const <Note>[]
        : store.searchNotes(tagIds: selected, matchAll: _matchAll);

    return Scaffold(
      appBar: AppBar(title: const Text('Etiquetas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar etiqueta por nombre',
                prefixIcon: Icon(Icons.manage_search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: allTags.isEmpty
                ? const EmptyMessage(
                    icon: Icons.sell_outlined,
                    message: 'No hay etiquetas.\n'
                        'Pulsa "Nueva etiqueta" para crear una.',
                  )
                : visibleTags.isEmpty
                    ? const EmptyMessage(
                        icon: Icons.find_in_page_outlined,
                        message: 'Ninguna etiqueta coincide con la búsqueda.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: visibleTags.length,
                        itemBuilder: (context, index) {
                          final tag = visibleTags[index];
                          return _TagTile(
                            tag: tag,
                            count: store.tagUsage(tag.id),
                            selected: selected.contains(tag.id),
                            onToggle: () => _toggleTag(tag.id),
                            onRename: () => _renameTag(tag),
                            onDelete: () => _deleteTag(tag),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.isEmpty
                      ? 'Selecciona una o varias etiquetas para agrupar notas'
                      : 'Notas encontradas: ${notes.length}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (selected.length > 1) ...[
                  const SizedBox(height: 8),
                  MatchModeSelector(
                    matchAll: _matchAll,
                    onChanged: (value) => setState(() => _matchAll = value),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: selected.isEmpty
                ? const EmptyMessage(
                    icon: Icons.ads_click,
                    message: 'Toca una etiqueta para ver las notas de '
                        'todos los proyectos que la tienen.',
                  )
                : notes.isEmpty
                    ? const EmptyMessage(
                        icon: Icons.sticky_note_2_outlined,
                        message: 'Ninguna nota tiene esta combinación de etiquetas.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                        itemCount: notes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final note = notes[index];
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        icon: const Icon(Icons.add),
        label: const Text('Nueva etiqueta'),
        onPressed: _createTag,
      ),
    );
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({
    required this.tag,
    required this.count,
    required this.selected,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
  });

  final Tag tag;
  final int count;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      onTap: onToggle,
      leading: Icon(
        selected ? Icons.check_circle : Icons.radio_button_unchecked,
      ),
      title: Text(tag.name),
      subtitle: Text('$count ${count == 1 ? 'nota' : 'notas'}'),
      trailing: PopupMenuButton<_TagAction>(
        tooltip: 'Opciones de la etiqueta',
        onSelected: (action) {
          if (action == _TagAction.rename) {
            onRename();
          } else {
            onDelete();
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: _TagAction.rename, child: Text('Renombrar')),
          PopupMenuItem(value: _TagAction.delete, child: Text('Eliminar')),
        ],
      ),
    );
  }
}
