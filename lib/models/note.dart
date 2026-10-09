/// Nota de investigación. Pertenece a un único proyecto y puede tener
/// varias etiquetas. Guarda los ids de las etiquetas, no sus nombres, para
/// que renombrar una etiqueta se refleje automáticamente en todas las notas.
class Note {
  Note({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required List<String> tagIds,
  }) : tagIds = List.unmodifiable(tagIds);

  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tagIds;

  Note copyWith({
    String? title,
    String? description,
    DateTime? updatedAt,
    List<String>? tagIds,
  }) {
    return Note(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}
