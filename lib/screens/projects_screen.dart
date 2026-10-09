import 'package:flutter/material.dart';

import '../models/project.dart';
import '../state/app_scope.dart';
import '../utils/navigation.dart';
import '../utils/text_utils.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_message.dart';
import '../widgets/project_form_dialog.dart';
import 'project_notes_screen.dart';

/// RF1. Lista de proyectos con crear, editar y eliminar.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final projects = store.projects;

    return Scaffold(
      appBar: AppBar(title: const Text('Proyectos')),
      body: projects.isEmpty
          ? const EmptyMessage(
              icon: Icons.collections_bookmark_outlined,
              message: 'Todavía no tienes proyectos.\n'
                  'Pulsa "Nuevo proyecto" para empezar.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: projects.length,
              itemBuilder: (context, index) =>
                  _ProjectCard(project: projects[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        // Sin Hero: esta pantalla sigue montada en el IndexedStack y su FAB
        // chocaría con el de las pantallas que se abren encima.
        heroTag: null,
        onPressed: () => showProjectFormDialog(
          context,
          store: AppScope.read(context),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proyecto'),
      ),
    );
  }
}

enum _ProjectAction { edit, delete }

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final count = store.noteCount(project.id);
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        onTap: () => pushScreen(
          context,
          ProjectNotesScreen(projectId: project.id),
        ),
        title: Text(
          project.name,
          style: theme.textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (project.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              '$count ${count == 1 ? 'nota' : 'notas'} · '
              'Modificado ${formatDate(project.updatedAt)}',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        trailing: PopupMenuButton<_ProjectAction>(
          tooltip: 'Opciones del proyecto',
          onSelected: (action) => _onAction(context, action, count),
          itemBuilder: (_) => const [
            PopupMenuItem(value: _ProjectAction.edit, child: Text('Editar')),
            PopupMenuItem(value: _ProjectAction.delete, child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    _ProjectAction action,
    int noteCount,
  ) async {
    final store = AppScope.read(context);

    if (action == _ProjectAction.edit) {
      await showProjectFormDialog(context, store: store, project: project);
      return;
    }

    final confirmed = await confirmAction(
      context,
      title: '¿Eliminar proyecto?',
      message: 'Se eliminarán "${project.name}" y sus $noteCount '
          '${noteCount == 1 ? 'nota' : 'notas'}. Las etiquetas se conservan.',
    );
    if (confirmed && context.mounted) {
      store.deleteProject(project.id);
    }
  }
}
