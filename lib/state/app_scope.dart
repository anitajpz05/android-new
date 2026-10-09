import 'package:flutter/widgets.dart';

import 'app_store.dart';

/// Entrega el [AppStore] a todo el árbol de widgets usando InheritedNotifier,
/// que viene en el SDK de Flutter.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    super.key,
    required AppStore store,
    required super.child,
  }) : super(notifier: store);

  /// Obtiene el almacén y suscribe el widget a sus cambios.
  /// Úsalo en build().
  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No hay un AppScope por encima de este widget');
    return scope!.notifier!;
  }

  /// Obtiene el almacén sin suscribirse. Úsalo en callbacks (onPressed, etc.).
  static AppStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No hay un AppScope por encima de este widget');
    return scope!.notifier!;
  }
}
