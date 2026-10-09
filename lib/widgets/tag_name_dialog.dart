import 'package:flutter/material.dart';

import '../models/tag.dart';
import '../state/app_store.dart';

/// Pide el nombre de una etiqueta nueva (tag == null) o renombrarla.
/// Rechaza nombres vacíos y nombres que ya existen. Devuelve el nombre
/// limpio, o null si se cancela.
Future<String?> showTagNameDialog(
  BuildContext context, {
  required AppStore store,
  Tag? tag,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TagNameDialog(store: store, tag: tag),
  );
}

class _TagNameDialog extends StatefulWidget {
  const _TagNameDialog({required this.store, this.tag});

  final AppStore store;
  final Tag? tag;

  @override
  State<_TagNameDialog> createState() => _TagNameDialogState();
}

class _TagNameDialogState extends State<_TagNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.tag?.name ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return 'El nombre es obligatorio';
    if (widget.store.isTagNameTaken(clean, exceptId: widget.tag?.id)) {
      return 'Ya existe una etiqueta con ese nombre';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tag == null ? 'Nueva etiqueta' : 'Renombrar etiqueta'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
          validator: _validate,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
