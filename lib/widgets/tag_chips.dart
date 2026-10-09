import 'package:flutter/material.dart';

import '../models/tag.dart';

/// Etiquetas en un Wrap, de modo que pasan a la línea siguiente si no caben.
///
/// - [onDeleted] convierte cada chip en un chip con botón de quitar (editor).
/// - [onTap] convierte cada chip en un chip pulsable (detalle de nota).
class TagChips extends StatelessWidget {
  const TagChips({
    super.key,
    required this.tags,
    this.onTap,
    this.onDeleted,
    this.emptyText,
  });

  final List<Tag> tags;
  final ValueChanged<Tag>? onTap;
  final ValueChanged<Tag>? onDeleted;

  /// Texto que se muestra si la lista está vacía.
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Text(
        emptyText ?? '',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final tag in tags) _buildChip(tag)],
    );
  }

  Widget _buildChip(Tag tag) {
    final avatar = _colorDot(tag);

    if (onDeleted != null) {
      return InputChip(
        label: Text(tag.name),
        avatar: avatar,
        onDeleted: () => onDeleted!(tag),
        deleteButtonTooltipMessage: 'Quitar etiqueta',
      );
    }

    return ActionChip(
      label: Text(tag.name),
      avatar: avatar,
      onPressed: onTap == null ? null : () => onTap!(tag),
    );
  }

  Widget? _colorDot(Tag tag) {
    final value = tag.colorValue;
    if (value == null) return null;
    return CircleAvatar(radius: 6, backgroundColor: Color(value));
  }
}
