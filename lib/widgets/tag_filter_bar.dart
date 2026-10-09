import 'package:flutter/material.dart';

import '../models/tag.dart';

/// Chips para seleccionar etiquetas como filtro.
/// Aparece el selector de modo cuando hay más de una seleccionada.
class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    super.key,
    required this.tags,
    required this.selectedIds,
    required this.onToggle,
    required this.matchAll,
    required this.onModeChanged,
  });

  final List<Tag> tags;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool matchAll;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final tag in tags)
              FilterChip(
                label: Text(tag.name),
                selected: selectedIds.contains(tag.id),
                onSelected: (_) => onToggle(tag.id),
              ),
          ],
        ),
        if (selectedIds.length > 1) ...[
          const SizedBox(height: 8),
          MatchModeSelector(matchAll: matchAll, onChanged: onModeChanged),
        ],
      ],
    );
  }
}

/// Elige entre notas con todas las etiquetas elegidas o con al menos una.
class MatchModeSelector extends StatelessWidget {
  const MatchModeSelector({
    super.key,
    required this.matchAll,
    required this.onChanged,
  });

  final bool matchAll;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: false, label: Text('Al menos una')),
        ButtonSegment(value: true, label: Text('Todas')),
      ],
      selected: {matchAll},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
