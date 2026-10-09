import 'package:flutter_test/flutter_test.dart';
import 'package:renotes/data/sample_data.dart';
import 'package:renotes/state/app_store.dart';

void main() {
  late AppStore store;

  setUp(() {
    store = AppStore.sample();
  });

  group('Datos de prueba', () {
    test('cumplen los mínimos del enunciado', () {
      final data = SampleData.build();

      expect(data.projects, hasLength(3));
      expect(data.notes, hasLength(15));
      expect(data.tags, hasLength(8));

      for (final project in data.projects) {
        final count = data.notes.where((n) => n.projectId == project.id).length;
        expect(count, greaterThanOrEqualTo(4), reason: project.name);
      }

      final longNotes = data.notes.where((n) => n.description.length > 600);
      expect(longNotes.length, greaterThanOrEqualTo(5));

      expect(data.notes.any((n) => n.tagIds.isEmpty), isTrue);
      expect(data.tags.any((t) => store.tagUsage(t.id) == 0), isTrue);

      final tagsInSeveralProjects = data.tags.where((tag) {
        final projects = data.notes
            .where((n) => n.tagIds.contains(tag.id))
            .map((n) => n.projectId)
            .toSet();
        return projects.length > 1;
      });
      expect(tagsInSeveralProjects.length, greaterThanOrEqualTo(3));
    });
  });

  group('Etiquetas', () {
    test('no se pueden crear duplicados ignorando mayúsculas y acentos', () {
      expect(store.createTag('METODOLOGÍA'), isNull);
      expect(store.createTag('  metodologia  '), isNull);
      expect(store.createTag('Nueva etiqueta'), isNotNull);
      expect(store.createTag('nueva etiqueta'), isNull);
    });

    test('getOrCreateTag reutiliza la existente', () {
      final before = store.tags.length;
      final tag = store.getOrCreateTag('estadistica');

      expect(tag.name, 'Estadística');
      expect(store.tags.length, before);
    });

    test('renombrar a un nombre existente se rechaza', () {
      final ideas = store.findTagByName('Ideas')!;

      expect(store.renameTag(ideas.id, 'pendiente'), isFalse);
      expect(store.renameTag(ideas.id, 'Ideas nuevas'), isTrue);
      expect(store.tagById(ideas.id)!.name, 'Ideas nuevas');
    });

    test('renombrar se refleja en las notas que la usan', () {
      final metodologia = store.findTagByName('Metodología')!;
      store.renameTag(metodologia.id, 'Método');

      final note = store.noteById('n2')!;
      expect(note.tagIds, contains(metodologia.id));
      expect(store.tagById(note.tagIds.first), isNotNull);
      expect(store.findTagByName('Método'), isNotNull);
    });

    test('eliminar una etiqueta la quita de las notas sin borrarlas', () {
      final metodologia = store.findTagByName('Metodología')!;
      final usageBefore = store.tagUsage(metodologia.id);
      final notesBefore = store.searchNotes().length;

      store.deleteTag(metodologia.id);

      expect(store.tagById(metodologia.id), isNull);
      expect(store.tagUsage(metodologia.id), 0);
      expect(store.searchNotes().length, notesBefore);
      expect(usageBefore, greaterThan(0));
    });

    test('tagsInProject solo muestra etiquetas de ese proyecto', () {
      final names = store.tagsInProject('p1').map((t) => t.name).toSet();

      expect(names, contains('Metodología'));
      expect(names, isNot(contains('Pendiente')));
      expect(names, isNot(contains('Ideas')));
    });

    test('suggestTags busca en cualquier parte del nombre y excluye asignadas', () {
      final suggestions = store
          .suggestTags(query: 'ODO')
          .map((t) => t.name)
          .toList();
      expect(suggestions, contains('Metodología'));

      final excluded = store.suggestTags(
        query: 'metodo',
        excludeIds: {store.findTagByName('Metodología')!.id},
      );
      expect(excluded, isEmpty);
    });
  });

  group('Proyectos y notas', () {
    test('eliminar un proyecto elimina sus notas pero conserva las etiquetas', () {
      final tagCount = store.tags.length;
      store.deleteProject('p2');

      expect(store.projectById('p2'), isNull);
      expect(store.noteById('n6'), isNull);
      expect(store.searchNotes(projectId: 'p2'), isEmpty);
      expect(store.tags.length, tagCount);
    });

    test('una misma etiqueta se asigna a notas de proyectos distintos', () {
      final metodologia = store.findTagByName('Metodología')!;
      final projects = store
          .searchNotes(tagIds: {metodologia.id})
          .map((n) => n.projectId)
          .toSet();

      expect(projects, {'p1', 'p2', 'p3'});
    });

    test('la búsqueda ignora mayúsculas y acentos en título y contenido', () {
      final byTitle = store.searchNotes(query: 'BIBLIOGRAFIA');
      expect(byTitle, isEmpty);

      final byContent = store.searchNotes(query: 'retroalimentacion');
      expect(byContent.map((n) => n.id), contains('n3'));
    });

    test('filtro por etiquetas: "todas" exige todas, "al menos una" basta con una', () {
      final estadistica = store.findTagByName('Estadística')!.id;
      final resultados = store.findTagByName('Resultados')!.id;

      final any = store.searchNotes(
        tagIds: {estadistica, resultados},
      );
      final all = store.searchNotes(
        tagIds: {estadistica, resultados},
        matchAll: true,
      );

      expect(any.length, greaterThan(all.length));
      for (final note in all) {
        expect(note.tagIds, containsAll([estadistica, resultados]));
      }
    });

    test('guardar una nota sin perder una descripción larga', () {
      final long = 'Párrafo de prueba con acentos y ñ. ' * 300;
      final saved = store.saveNote(
        projectId: 'p1',
        title: '  Nota larga  ',
        description: long,
        tagIds: const ['t1', 't1'],
      );

      expect(saved.title, 'Nota larga');
      expect(saved.description, long);
      expect(saved.tagIds, ['t1']);
      expect(store.noteById(saved.id)!.description.length, long.length);
    });

    test('editar una nota conserva su fecha de creación', () {
      final original = store.noteById('n1')!;
      store.saveNote(
        id: 'n1',
        projectId: 'p1',
        title: 'Título nuevo',
        description: original.description,
        tagIds: original.tagIds,
      );

      final updated = store.noteById('n1')!;
      expect(updated.title, 'Título nuevo');
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
    });

    test('cada cambio notifica a los oyentes', () {
      var notifications = 0;
      store.addListener(() => notifications++);

      store.createTag('Nueva');
      store.deleteNote('n5');
      store.renameTag('t8', 'Ideas 2');

      expect(notifications, 3);
    });
  });
}
