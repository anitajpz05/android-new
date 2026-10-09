import 'package:flutter/material.dart';

import '../models/tag.dart';
import '../state/app_scope.dart';

/// Campo de etiquetas con autocompletado (RawAutocomplete del SDK).
///
/// - Sugiere etiquetas existentes que contienen el texto, sin distinguir
///   mayúsculas ni acentos, y excluye las que la nota ya tiene.
/// - Si el texto no coincide con ninguna etiqueta, ofrece crearla.
/// - Enter o una coma confirman el texto escrito.
class TagAutocompleteField extends StatefulWidget {
  const TagAutocompleteField({
    super.key,
    required this.assignedIds,
    required this.onTagSelected,
  });

  /// Ids de las etiquetas que la nota ya tiene asignadas.
  final Set<String> assignedIds;

  /// Se llama con la etiqueta a asignar (existente o recién creada).
  final ValueChanged<Tag> onTagSelected;

  @override
  State<TagAutocompleteField> createState() => _TagAutocompleteFieldState();
}

/// Una opción del desplegable: una etiqueta existente o una nueva por crear.
class _Suggestion {
  const _Suggestion(this.name, this.tag);

  final String name;

  /// null cuando la opción es crear una etiqueta nueva.
  final Tag? tag;

  bool get isNew => tag == null;
}

class _TagAutocompleteFieldState extends State<TagAutocompleteField> {
  // RawAutocomplete exige pasar el controlador y el FocusNode juntos,
  // así que se crean aquí y se controlan desde este State.
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Iterable<_Suggestion> _optionsFor(String text) {
    final query = _clean(text);
    if (query.isEmpty) return const [];

    final store = AppScope.read(context);
    final suggestions = store
        .suggestTags(query: query, excludeIds: widget.assignedIds)
        .map((tag) => _Suggestion(tag.name, tag))
        .toList();

    // Solo se ofrece crear si no existe ninguna etiqueta con ese nombre,
    // ni siquiera asignada, para no crear duplicados.
    if (store.findTagByName(query) == null) {
      suggestions.add(_Suggestion(query, null));
    }
    return suggestions;
  }

  void _select(_Suggestion suggestion) {
    final tag = suggestion.tag ?? AppScope.read(context).getOrCreateTag(suggestion.name);
    widget.onTagSelected(tag);
    _controller.clear();
  }

  /// Enter o coma: asigna la etiqueta que coincide exactamente; si no hay
  /// coincidencia exacta, la primera sugerencia; si no hay ninguna, la crea.
  void _commit(String raw) {
    final text = _clean(raw);
    if (text.isEmpty) {
      _controller.clear();
      return;
    }

    final store = AppScope.read(context);
    final exact = store.findTagByName(text);
    final Tag tag;
    if (exact != null) {
      tag = exact;
    } else {
      final matches = store.suggestTags(query: text, excludeIds: widget.assignedIds);
      tag = matches.isNotEmpty ? matches.first : store.getOrCreateTag(text);
    }

    if (!widget.assignedIds.contains(tag.id)) {
      widget.onTagSelected(tag);
    }
    _controller.clear();
  }

  String _clean(String text) => text.replaceAll(',', '').trim();

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<_Suggestion>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (suggestion) => suggestion.name,
      optionsBuilder: (value) => _optionsFor(value.text),
      onSelected: _select,
      fieldViewBuilder: (context, textController, focusNode, _) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Añadir etiqueta',
            hintText: 'Escribe para buscar o crear',
            helperText: 'Enter o coma para confirmar',
            prefixIcon: Icon(Icons.local_offer_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.contains(',')) _commit(value);
          },
          onSubmitted: _commit,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final maxWidth = MediaQuery.sizeOf(context).width - 64;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 220, maxWidth: maxWidth),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final suggestion = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      suggestion.isNew
                          ? Icons.playlist_add
                          : Icons.local_offer_outlined,
                    ),
                    title: Text(
                      suggestion.isNew
                          ? 'Crear etiqueta "${suggestion.name}"'
                          : suggestion.name,
                    ),
                    onTap: () => onSelected(suggestion),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
