import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/tag.dart';
import '../utils/text_utils.dart';

/// Almacén en memoria de proyectos, notas y etiquetas.
///
/// Es el único punto que modifica los datos. Cada cambio llama a
/// [notifyListeners], y las pantallas que leen el almacén se reconstruyen solas.
class AppStore extends ChangeNotifier {
  AppStore({
    required List<Project> projects,
    required List<Note> notes,
    required List<Tag> tags,
  })  : _projects = List.of(projects),
        _notes = List.of(notes),
        _tags = List.of(tags);

  /// Almacén con los datos de prueba del proyecto.
  factory AppStore.sample() {
    final data = SampleData.build();
    return AppStore(
      projects: data.projects,
      notes: data.notes,
      tags: data.tags,
    );
  }

  final List<Project> _projects;
  final List<Note> _notes;
  final List<Tag> _tags;

  static int _idCounter = 0;

  // ---------------------------------------------------------------------------
  // Proyectos
  // ---------------------------------------------------------------------------

  /// Proyectos ordenados por última modificación (más reciente primero).
  List<Project> get projects =>
      [..._projects]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  Project? projectById(String id) => _findById(_projects, (p) => p.id == id);

  int noteCount(String projectId) =>
      _notes.where((n) => n.projectId == projectId).length;

  Project addProject({required String name, String description = ''}) {
    assert(name.trim().isNotEmpty, 'El nombre del proyecto es obligatorio');
    final now = DateTime.now();
    final project = Project(
      id: _newId('p'),
      name: name.trim(),
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _projects.add(project);
    notifyListeners();
    return project;
  }

  void updateProject(
    String id, {
    required String name,
    required String description,
  }) {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1 || name.trim().isEmpty) return;
    _projects[index] = _projects[index].copyWith(
      name: name.trim(),
      description: description.trim(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Elimina el proyecto y sus notas. Las etiquetas se conservan.
  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _notes.removeWhere((n) => n.projectId == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Notas
  // ---------------------------------------------------------------------------

  Note? noteById(String id) => _findById(_notes, (n) => n.id == id);

  /// Notas de un proyecto. Sin filtros; la pantalla filtra con [searchNotes].
  List<Note> notesInProject(String projectId) =>
      searchNotes(projectId: projectId);

  /// Busca notas por texto (título o descripción), proyecto y etiquetas.
  ///
  /// - [tagIds] vacío significa "sin filtro de etiquetas".
  /// - [matchAll] true: la nota debe tener todas las etiquetas indicadas.
  ///   false: basta con que tenga al menos una.
  List<Note> searchNotes({
    String query = '',
    String? projectId,
    Set<String> tagIds = const {},
    bool matchAll = false,
  }) {
    final normalizedQuery = normalizeText(query);
    final results = _notes.where((note) {
      if (projectId != null && note.projectId != projectId) return false;
      if (tagIds.isNotEmpty) {
        final matches = matchAll
            ? tagIds.every(note.tagIds.contains)
            : tagIds.any(note.tagIds.contains);
        if (!matches) return false;
      }
      if (normalizedQuery.isEmpty) return true;
      return normalizeText(note.title).contains(normalizedQuery) ||
          normalizeText(note.description).contains(normalizedQuery);
    }).toList();

    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results;
  }

  /// Crea una nota si [id] es null o no existe; si existe, la actualiza.
  Note saveNote({
    String? id,
    required String projectId,
    required String title,
    required String description,
    required List<String> tagIds,
  }) {
    assert(title.trim().isNotEmpty, 'El título de la nota es obligatorio');
    final now = DateTime.now();
    final uniqueTagIds = tagIds.toSet().toList();
    final index = id == null ? -1 : _notes.indexWhere((n) => n.id == id);

    final Note saved;
    if (index == -1) {
      saved = Note(
        id: _newId('n'),
        projectId: projectId,
        title: title.trim(),
        // La descripción se guarda tal cual para no perder contenido.
        description: description,
        createdAt: now,
        updatedAt: now,
        tagIds: uniqueTagIds,
      );
      _notes.add(saved);
    } else {
      saved = _notes[index].copyWith(
        title: title.trim(),
        description: description,
        tagIds: uniqueTagIds,
        updatedAt: now,
      );
      _notes[index] = saved;
    }

    _touchProject(projectId, now);
    notifyListeners();
    return saved;
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void _touchProject(String projectId, DateTime when) {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index == -1) return;
    _projects[index] = _projects[index].copyWith(updatedAt: when);
  }

  // ---------------------------------------------------------------------------
  // Etiquetas
  // ---------------------------------------------------------------------------

  /// Todas las etiquetas ordenadas por nombre normalizado.
  List<Tag> get tags => [..._tags]
    ..sort((a, b) => normalizeText(a.name).compareTo(normalizeText(b.name)));

  Tag? tagById(String id) => _findById(_tags, (t) => t.id == id);

  /// Busca una etiqueta por nombre ignorando mayúsculas, acentos y espacios.
  Tag? findTagByName(String name) {
    final key = normalizeText(name);
    if (key.isEmpty) return null;
    return _findById(_tags, (t) => normalizeText(t.name) == key);
  }

  bool isTagNameTaken(String name, {String? exceptId}) {
    final existing = findTagByName(name);
    return existing != null && existing.id != exceptId;
  }

  /// Crea una etiqueta. Devuelve null si el nombre está vacío o ya existe.
  Tag? createTag(String name, {int? colorValue}) {
    final clean = name.trim();
    if (clean.isEmpty || findTagByName(clean) != null) return null;
    final tag = Tag(id: _newId('t'), name: clean, colorValue: colorValue);
    _tags.add(tag);
    notifyListeners();
    return tag;
  }

  /// Devuelve la etiqueta con ese nombre o la crea si no existe.
  /// Evita duplicados: nunca crea una etiqueta cuyo nombre ya exista.
  Tag getOrCreateTag(String name) {
    assert(name.trim().isNotEmpty, 'El nombre de la etiqueta es obligatorio');
    return findTagByName(name) ?? createTag(name)!;
  }

  /// Renombra una etiqueta. Devuelve false si el nuevo nombre ya existe.
  /// Las notas guardan ids, así que el cambio se refleja en todas ellas.
  bool renameTag(String id, String newName) {
    final clean = newName.trim();
    final index = _tags.indexWhere((t) => t.id == id);
    if (index == -1 || clean.isEmpty || isTagNameTaken(clean, exceptId: id)) {
      return false;
    }
    _tags[index] = _tags[index].copyWith(name: clean);
    notifyListeners();
    return true;
  }

  /// Elimina la etiqueta de todas las notas. Las notas no se borran.
  void deleteTag(String id) {
    _tags.removeWhere((t) => t.id == id);
    for (var i = 0; i < _notes.length; i++) {
      final note = _notes[i];
      if (note.tagIds.contains(id)) {
        _notes[i] = note.copyWith(
          tagIds: note.tagIds.where((tagId) => tagId != id).toList(),
        );
      }
    }
    notifyListeners();
  }

  /// Número de notas (de cualquier proyecto) que usan la etiqueta.
  int tagUsage(String tagId) =>
      _notes.where((n) => n.tagIds.contains(tagId)).length;

  /// Etiquetas que aparecen en las notas de un proyecto concreto.
  List<Tag> tagsInProject(String projectId) {
    final used = _notes
        .where((n) => n.projectId == projectId)
        .expand((n) => n.tagIds)
        .toSet();
    return tags.where((t) => used.contains(t.id)).toList();
  }

  /// Etiquetas cuyo nombre contiene el texto escrito (sin distinguir
  /// mayúsculas ni acentos), excluyendo las ya asignadas. Las que empiezan
  /// por el texto aparecen primero.
  List<Tag> suggestTags({
    required String query,
    Set<String> excludeIds = const {},
  }) {
    final key = normalizeText(query);
    if (key.isEmpty) return const [];

    final matches = tags
        .where((t) =>
            !excludeIds.contains(t.id) && normalizeText(t.name).contains(key))
        .toList();
    matches.sort((a, b) {
      final aStarts = normalizeText(a.name).startsWith(key) ? 0 : 1;
      final bStarts = normalizeText(b.name).startsWith(key) ? 0 : 1;
      return aStarts.compareTo(bStarts);
    });
    return matches;
  }

  // ---------------------------------------------------------------------------
  // Utilidades internas
  // ---------------------------------------------------------------------------

  String _newId(String prefix) {
    _idCounter++;
    return '$prefix${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  T? _findById<T>(Iterable<T> items, bool Function(T item) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }
}
