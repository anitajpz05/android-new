import 'package:flutter/material.dart';

import 'projects_screen.dart';
import 'search_screen.dart';
import 'tags_screen.dart';

/// Contenedor con la BottomNavigationBar de tres destinos.
///
/// IndexedStack mantiene vivos los tres destinos, así que cada uno conserva
/// su texto de búsqueda, sus filtros y su posición de scroll al cambiar de pestaña.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          ProjectsScreen(),
          TagsScreen(),
          SearchScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _index = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.sell),
            label: 'Etiquetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'Buscar',
          ),
        ],
      ),
    );
  }
}
