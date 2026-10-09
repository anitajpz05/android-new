import 'package:flutter/material.dart';

/// Única forma de navegar en la app: Navigator.push con MaterialPageRoute.
/// No se usan rutas nombradas ni go_router.
Future<T?> pushScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(builder: (_) => screen),
  );
}
