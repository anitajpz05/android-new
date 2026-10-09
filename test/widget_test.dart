import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renotes/main.dart';
import 'package:renotes/screens/note_editor_screen.dart';
import 'package:renotes/state/app_scope.dart';
import 'package:renotes/state/app_store.dart';

void main() {
  testWidgets('la app arranca con la pestaña Proyectos y los datos de prueba',
      (tester) async {
    await tester.pumpWidget(const ReNotesApp());

    expect(find.text('Proyectos'), findsWidgets);
    expect(find.text('Inteligencia artificial en educación'), findsOneWidget);
    expect(find.text('Movilidad urbana sostenible'), findsOneWidget);
  });

  testWidgets('la pestaña Etiquetas lista las etiquetas con su uso',
      (tester) async {
    await tester.pumpWidget(const ReNotesApp());

    await tester.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Etiquetas'),
    ));
    await tester.pumpAndSettle();

    // La lista es perezosa y la zona superior es pequeña en la prueba:
    // se comprueba la primera etiqueta alfabética, que sí está visible.
    expect(find.text('Bibliografía'), findsOneWidget);
    expect(find.text('4 notas'), findsWidgets);
  });

  testWidgets('el autocompletado sugiere etiquetas existentes sin distinguir acentos',
      (tester) async {
    final store = AppStore.sample();
    await tester.pumpWidget(
      AppScope(
        store: store,
        child: const MaterialApp(
          home: NoteEditorScreen(projectId: 'p1'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).last, 'estadis');
    await tester.pumpAndSettle();

    expect(find.text('Estadística'), findsOneWidget);

    await tester.tap(find.text('Estadística'));
    await tester.pumpAndSettle();

    // La etiqueta asignada aparece como chip y el campo se ha limpiado.
    expect(find.byType(InputChip), findsOneWidget);
    expect(find.text('Estadística'), findsOneWidget);
    expect(find.text('estadis'), findsNothing);
    expect(store.tagsInProject('p1').map((t) => t.name), contains('Estadística'));
  });

  testWidgets('el autocompletado ofrece crear una etiqueta nueva',
      (tester) async {
    final store = AppStore.sample();
    await tester.pumpWidget(
      AppScope(
        store: store,
        child: const MaterialApp(
          home: NoteEditorScreen(projectId: 'p1'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).last, 'Ética');
    await tester.pumpAndSettle();

    expect(find.text('Crear etiqueta "Ética"'), findsOneWidget);

    await tester.tap(find.text('Crear etiqueta "Ética"'));
    await tester.pumpAndSettle();

    expect(store.findTagByName('etica'), isNotNull);
    expect(store.findTagByName('Ética')!.name, 'Ética');
  });
}
