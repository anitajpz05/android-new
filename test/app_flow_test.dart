import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renotes/main.dart';
import 'package:renotes/screens/search_screen.dart';
import 'package:renotes/screens/tags_screen.dart';

/// Busca dentro del diálogo que está abierto.
Finder inDialog(Finder finder) =>
    find.descendant(of: find.byType(AlertDialog), matching: finder);

/// Destino de la BottomNavigationBar (no los títulos de pantalla).
Finder navItem(String label) => find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    );

/// ListTile cuyo título es exactamente [name]. Evita coincidencias parciales
/// (p. ej. «Resultados» también aparece como chip en las notas).
Finder tileTitled(String name) => find.byWidgetPredicate(
      (w) => w is ListTile && w.title is Text && (w.title! as Text).data == name,
    );

/// Botón de menú (⋮) de la tarjeta de lista que contiene [name].
Finder menuOf(String name) => find.descendant(
      of: tileTitled(name),
      matching: find.byIcon(Icons.more_vert),
    );

Future<void> launch(WidgetTester tester) async {
  // Tamaño parecido a un móvil Android real (1080x2400).
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ReNotesApp());
  await tester.pumpAndSettle();
}

Future<void> settle(WidgetTester tester) => tester.pumpAndSettle();

/// Desplaza la lista de etiquetas hasta que aparezca [name].
Future<void> scrollTagsTo(WidgetTester tester, String name) =>
    scrollWithin(tester, TagsScreen, tileTitled(name));

/// Arrastra la lista de la pantalla [screen] hasta que [target] esté construido.
/// Las listas son perezosas: un elemento fuera de pantalla no existe en el árbol.
Future<void> scrollWithin(WidgetTester tester, Type screen, Finder target) async {
  final list = find
      .descendant(of: find.byType(screen), matching: find.byType(ListView))
      .first;
  for (var i = 0; i < 30 && target.evaluate().isEmpty; i++) {
    await tester.drag(list, const Offset(0, -300));
    await settle(tester);
  }
}

/// Botón (ButtonStyleButton, incluidos los que llevan icono) con esa etiqueta.
Finder buttonWith(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );

/// Campo de búsqueda de la pantalla Buscar (no el de Etiquetas, que sigue montado).
Finder searchField() => find.descendant(
      of: find.byType(SearchScreen),
      matching: find.byType(TextField),
    );

void main() {
  testWidgets('proyectos: validación, crear, editar, cancelar y eliminar',
      (tester) async {
    await launch(tester);

    // Validación: el nombre es obligatorio.
    await tester.tap(find.text('Nuevo proyecto'));
    await settle(tester);
    await tester.tap(inDialog(find.text('Guardar')));
    await settle(tester);
    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    await tester.tap(inDialog(find.text('Cancelar')));
    await settle(tester);

    // Crear.
    await tester.tap(find.text('Nuevo proyecto'));
    await settle(tester);
    await tester.enterText(
        inDialog(find.byType(TextFormField)).first, 'Proyecto de prueba');
    await tester.tap(inDialog(find.text('Guardar')));
    await settle(tester);
    expect(tileTitled('Proyecto de prueba'), findsOneWidget);
    expect(find.textContaining('0 notas'), findsOneWidget);

    // Editar.
    await tester.tap(menuOf('Proyecto de prueba'));
    await settle(tester);
    await tester.tap(find.text('Editar'));
    await settle(tester);
    await tester.enterText(
        inDialog(find.byType(TextFormField)).first, 'Proyecto editado');
    await tester.tap(inDialog(find.text('Guardar')));
    await settle(tester);
    expect(tileTitled('Proyecto editado'), findsOneWidget);
    expect(tileTitled('Proyecto de prueba'), findsNothing);

    // Eliminar: cancelar no borra, confirmar sí.
    await tester.tap(menuOf('Proyecto editado'));
    await settle(tester);
    await tester.tap(find.text('Eliminar'));
    await settle(tester);
    expect(find.text('¿Eliminar proyecto?'), findsOneWidget);
    await tester.tap(inDialog(find.text('Cancelar')));
    await settle(tester);
    expect(tileTitled('Proyecto editado'), findsOneWidget);

    await tester.tap(menuOf('Proyecto editado'));
    await settle(tester);
    await tester.tap(find.text('Eliminar'));
    await settle(tester);
    await tester.tap(inDialog(find.text('Eliminar')));
    await settle(tester);
    expect(tileTitled('Proyecto editado'), findsNothing);
  });

  testWidgets('notas: validación, etiqueta nueva con coma, descartar, editar y eliminar',
      (tester) async {
    await launch(tester);
    await tester.tap(tileTitled('Inteligencia artificial en educación'));
    await settle(tester);
    expect(find.text('5 notas en el proyecto'), findsOneWidget);

    // Nueva nota: el título es obligatorio.
    await tester.tap(find.text('Nueva nota'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await settle(tester);
    expect(find.text('El título es obligatorio'), findsOneWidget);

    // Rellenar: título, descripción larga y una etiqueta nueva confirmada con coma.
    const longText = 'Texto de prueba con acentos y ñ, sin pérdida de contenido. ';
    final description = longText * 30; // más de 1.000 caracteres
    await tester.enterText(find.byType(TextFormField).at(0), 'Nota de prueba');
    await tester.enterText(find.byType(TextFormField).at(1), description);
    await tester.enterText(find.byType(TextField).last, 'Prueba,');
    await settle(tester);
    expect(find.widgetWithText(InputChip, 'Prueba'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await settle(tester);
    expect(find.text('Nota de prueba'), findsOneWidget);

    // Detalle: la descripción completa se conserva.
    await tester.tap(find.text('Nota de prueba'));
    await settle(tester);
    final shown = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(shown.data, description);

    // Editar, y al salir con cambios aparece el aviso.
    await tester.tap(buttonWith('Editar'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Nota editada');
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    expect(find.text('Cambios sin guardar'), findsOneWidget);

    // Cancelar el aviso: se queda en el editor.
    await tester.tap(inDialog(find.text('Cancelar')));
    await settle(tester);
    expect(find.text('Editar nota'), findsOneWidget);

    // Guardar el cambio.
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await settle(tester);
    expect(find.text('Nota editada'), findsOneWidget);

    // Cambios descartados: el título vuelve al guardado.
    await tester.tap(buttonWith('Editar'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Otro título');
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    await tester.tap(inDialog(find.text('Descartar')));
    await settle(tester);
    expect(find.text('Nota editada'), findsOneWidget);
    expect(find.text('Otro título'), findsNothing);

    // Volver a la lista y eliminar la nota con confirmación.
    await tester.pageBack();
    await settle(tester);
    await tester.tap(find.byTooltip('Eliminar nota').first);
    await settle(tester);
    await tester.tap(inDialog(find.text('Eliminar')));
    await settle(tester);
    expect(find.text('Nota editada'), findsNothing);
    // Quedaban 5 notas de prueba más la creada en esta prueba, menos una eliminada.
    expect(find.text('5 notas en el proyecto'), findsOneWidget);
  });

  testWidgets('detalle: eliminar desde el detalle y nota sin etiquetas',
      (tester) async {
    await launch(tester);
    await tester.tap(tileTitled('Inteligencia artificial en educación'));
    await settle(tester);
    await tester.tap(find.text('Notas sueltas de la reunión'));
    await settle(tester);
    expect(find.text('Esta nota no tiene etiquetas.'), findsOneWidget);

    await tester.tap(buttonWith('Eliminar'));
    await settle(tester);
    await tester.tap(inDialog(find.text('Eliminar')));
    await settle(tester);
    expect(find.text('4 notas en el proyecto'), findsOneWidget);
    expect(find.text('Notas sueltas de la reunión'), findsNothing);
  });

  testWidgets('etiquetas: crear, duplicados, renombrar, eliminar con aviso y agrupar',
      (tester) async {
    await launch(tester);
    await tester.tap(navItem('Etiquetas'));
    await settle(tester);

    // Crear una etiqueta independiente de cualquier nota.
    await tester.tap(find.text('Nueva etiqueta'));
    await settle(tester);
    await tester.enterText(inDialog(find.byType(TextFormField)), 'Ética');
    await tester.tap(inDialog(find.text('Guardar')));
    await settle(tester);
    expect(find.text('Ética'), findsOneWidget);

    // No se pueden crear duplicados (sin distinguir mayúsculas ni acentos).
    await tester.tap(find.text('Nueva etiqueta'));
    await settle(tester);
    await tester.enterText(inDialog(find.byType(TextFormField)), 'etica');
    await tester.tap(inDialog(find.text('Guardar')));
    await settle(tester);
    expect(find.text('Ya existe una etiqueta con ese nombre'), findsOneWidget);
    await tester.tap(inDialog(find.text('Cancelar')));
    await settle(tester);

    // Renombrar a un nombre existente se rechaza.
    await scrollTagsTo(tester, 'Ideas');
    await tester.tap(menuOf('Ideas'));
    await settle(tester);
    await tester.tap(find.text('Renombrar'));
    await settle(tester);
    await tester.enterText(inDialog(find.byType(TextFormField)), 'Pendiente');
    await tester.tap(inDialog(find.text('Guardar')));
    await settle(tester);
    expect(find.text('Ya existe una etiqueta con ese nombre'), findsOneWidget);
    await tester.tap(inDialog(find.text('Cancelar')));
    await settle(tester);

    // Renombrar a un nombre libre se refleja en la lista.
    await tester.tap(menuOf('Ideas'));
    await settle(tester);
    await tester.tap(find.text('Renombrar'));
    await settle(tester);
    await tester.enterText(inDialog(find.byType(TextFormField)), 'Ideas 2');
    await tester.tap(inDialog(find.text('Guardar')));
    await settle(tester);
    expect(tileTitled('Ideas 2'), findsOneWidget);

    // Eliminar una etiqueta usada muestra cuántas notas se verán afectadas.
    await scrollTagsTo(tester, 'Metodología');
    await tester.tap(menuOf('Metodología'));
    await settle(tester);
    await tester.tap(find.text('Eliminar'));
    await settle(tester);
    expect(find.text('Se quitará de 4 notas. Las notas no se borrarán.'),
        findsOneWidget);
    await tester.tap(inDialog(find.text('Cancelar')));
    await settle(tester);

    // Eliminar una etiqueta sin uso.
    await scrollTagsTo(tester, 'Ideas 2');
    await tester.tap(menuOf('Ideas 2'));
    await settle(tester);
    await tester.tap(find.text('Eliminar'));
    await settle(tester);
    expect(find.text('Esta etiqueta no se usa en ninguna nota.'), findsOneWidget);
    await tester.tap(inDialog(find.text('Eliminar')));
    await settle(tester);
    expect(tileTitled('Ideas 2'), findsNothing);

    // Búsqueda de etiquetas por nombre.
    await tester.enterText(find.byType(TextField).first, 'estad');
    await settle(tester);
    expect(tileTitled('Estadística'), findsOneWidget);
    expect(tileTitled('Bibliografía'), findsNothing);
    await tester.enterText(find.byType(TextField).first, '');
    await settle(tester);

    // Agrupar: "al menos una" (unión) frente a "todas" (intersección).
    await tester.tap(tileTitled('Estadística'));
    await settle(tester);
    await scrollTagsTo(tester, 'Resultados');
    await tester.tap(tileTitled('Resultados'));
    await settle(tester);
    expect(find.text('Notas encontradas: 4'), findsOneWidget);
    await tester.tap(find.text('Todas'));
    await settle(tester);
    expect(find.text('Notas encontradas: 3'), findsOneWidget);

    // Las notas listadas muestran su proyecto.
    expect(find.textContaining('Proyecto: '), findsWidgets);
  });

  testWidgets('buscar: texto, sin resultados y filtro por proyecto', (tester) async {
    await launch(tester);
    await tester.tap(navItem('Buscar'));
    await settle(tester);

    await tester.enterText(searchField(), 'piloto');
    await settle(tester);
    await scrollWithin(tester, SearchScreen, find.text('Resultados del piloto'));
    expect(find.text('Resultados del piloto'), findsOneWidget);

    await tester.enterText(searchField(), 'zzzz');
    await settle(tester);
    expect(find.text('No hay notas que coincidan con la búsqueda.'), findsOneWidget);

    await tester.enterText(searchField(), '');
    await settle(tester);
    await tester.tap(find.text('Todos los proyectos'));
    await settle(tester);
    await tester.tap(find.text('Movilidad urbana sostenible').last);
    await settle(tester);
    expect(find.text('Proyecto: Inteligencia artificial en educación'), findsNothing);
    expect(find.text('Proyecto: Movilidad urbana sostenible'), findsWidgets);
  });
}
