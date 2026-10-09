import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/tag.dart';
import '../state/app_scope.dart';
import '../utils/text_utils.dart';

/// Tarjeta de una nota: título, extracto, etiquetas y fecha de modificación.
/// Se usa en las listas de notas de proyecto, de etiquetas y de búsqueda.
class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    this.projectName,
    this.trailing,
  });

  final Note note;
  final VoidCallback onTap;

  /// Si se indica, se muestra el proyecto al que pertenece la nota.
  final String? projectName;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final tags = note.tagIds
        .map(store.tagById)
        .whereType<Tag>()
        .toList();
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (projectName != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Proyecto: $projectName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            if (note.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  excerpt(note.description),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final tag in tags)
                    Chip(
                      label: Text(tag.name),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Modificada ${formatDate(note.updatedAt)}',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
