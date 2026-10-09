import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'state/app_scope.dart';
import 'state/app_store.dart';

void main() {
  runApp(const ReNotesApp());
}

class ReNotesApp extends StatefulWidget {
  const ReNotesApp({super.key});

  @override
  State<ReNotesApp> createState() => _ReNotesAppState();
}

class _ReNotesAppState extends State<ReNotesApp> {
  // Los datos viven en memoria mientras la app está abierta y se cargan
  // desde los datos de prueba al iniciarla.
  final AppStore _store = AppStore.sample();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: _store,
      child: MaterialApp(
        title: 'ReNotes',
        debugShowCheckedModeBanner: false,
        // Paleta oscura: azul marino profundo con acentos ámbar.
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF1E3A5F),
          scaffoldBackgroundColor: const Color(0xFF0D1520),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D1520),
            foregroundColor: Color(0xFFE6EDF5),
            elevation: 0,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color(0xFF111B28),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF111B28),
            selectedItemColor: Color(0xFFFFB74D),
            unselectedItemColor: Color(0xFF8A9BB0),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF162335),
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFB74D),
            foregroundColor: Color(0xFF0D1520),
          ),
        ),
        home: const HomeShell(),
      ),
    );
  }
}
