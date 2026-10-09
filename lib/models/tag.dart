/// Etiqueta global. No pertenece a ningún proyecto y puede usarse en notas
/// de cualquier proyecto.
class Tag {
  const Tag({required this.id, required this.name, this.colorValue});

  final String id;
  final String name;

  /// Color opcional en formato ARGB, por ejemplo 0xFF3949AB.
  final int? colorValue;

  Tag copyWith({String? name}) {
    return Tag(id: id, name: name ?? this.name, colorValue: colorValue);
  }
}
