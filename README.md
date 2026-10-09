# ReNotes

Aplicación Flutter para Android (Notas de Investigación) desarrollada para la
asignatura Programación para Dispositivos Móviles.

ReNotes permite organizar el trabajo de investigación en **proyectos**, escribir
**notas** de texto largo dentro de cada proyecto y clasificarlas con
**etiquetas** globales que el usuario crea y reutiliza.

No usa servidor, base de datos, almacenamiento local ni autenticación. Todos los
datos viven en memoria mientras la app está abierta y se cargan desde datos de
prueba al iniciarla.

## Requisitos

- Flutter SDK 3.x (probado con Flutter 3.47.5, canal stable)
- Android SDK con un emulador o un dispositivo Android conectado
- Dart SDK incluido con Flutter

Comprueba tu entorno con:

```bash
flutter doctor
```

## Cómo inicializar y ejecutar el proyecto

1. Clona el repositorio y entra en la carpeta del proyecto.

2. Descarga las dependencias (el proyecto solo depende del SDK de Flutter):

   ```bash
   flutter pub get
   ```

3. Inicia un emulador de Android o conecta un dispositivo con depuración USB
   activada, y comprueba que aparece:

   ```bash
   flutter devices
   ```

4. Ejecuta la aplicación:

   ```bash
   flutter run
   ```

   Para generar un APK de depuración:

   ```bash
   flutter build apk --debug
   ```

## Pruebas y análisis estático

```bash
flutter analyze
flutter test
```

Las pruebas cubren las reglas del almacén (etiquetas únicas, borrados en
cascada, renombrado, filtros), la normalización de texto, los datos de prueba
y dos flujos de interfaz: el autocompletado de etiquetas y la pestaña Etiquetas.

## Estructura del proyecto

```
lib/
├── main.dart              # Punto de entrada y configuración de la app
├── data/
│   └── sample_data.dart   # Datos de prueba cargados al iniciar
├── models/                # Proyecto, Nota y Etiqueta
├── state/
│   ├── app_store.dart     # Datos y reglas de negocio (ChangeNotifier)
│   └── app_scope.dart     # Acceso al almacén mediante InheritedNotifier
├── screens/               # Las seis pantallas de la app
├── widgets/               # Componentes reutilizables
└── utils/                 # Normalización de texto, formatos y navegación
test/                      # Pruebas unitarias y de interfaz
```

## Gestión de estado y navegación

- **Estado:** solo se usan herramientas del SDK de Flutter (`ChangeNotifier`
  e `InheritedNotifier`). No se usan Provider, Riverpod ni otros paquetes de estado.
- **Navegación:** solo `Navigator.push` con `MaterialPageRoute`. No se usan
  rutas nombradas ni `go_router`.
- **Pestañas:** `BottomNavigationBar` con tres destinos (Proyectos, Etiquetas,
  Buscar) sobre un `IndexedStack`, de modo que cada pestaña conserva su
  búsqueda, sus filtros y su posición de scroll.
- **Autocompletado:** `RawAutocomplete` del SDK.

## Pantallas

| # | Pantalla | Descripción |
|---|----------|-------------|
| 1 | Proyectos | Lista de proyectos con nº de notas y fecha de modificación. Crear, editar y eliminar proyectos. |
| 2 | Notas del proyecto | Notas de un proyecto con búsqueda, filtro por etiquetas (todas o al menos una) y creación de notas. |
| 3 | Editor de nota | Crear o editar una nota: título validado, descripción multilínea y etiquetas con autocompletado. |
| 4 | Detalle de nota | Contenido completo de la nota, etiquetas en `Wrap` y acciones de editar y eliminar. |
| 5 | Etiquetas | Todas las etiquetas con su uso, creación, renombrado, eliminación y agrupación de notas por una o varias etiquetas. |
| 6 | Buscar | Búsqueda global por título o contenido, con filtros opcionales por proyecto y etiquetas. |

## Reglas de etiquetas

- Las etiquetas son globales y no pertenecen a ningún proyecto.
- El nombre es único. La comparación ignora mayúsculas, minúsculas, acentos y
  espacios al inicio o al final: `Metodología`, `metodologia` y `METODOLOGIA`
  son la misma etiqueta.
- Al escribir en el editor se sugieren etiquetas existentes en cualquier
  proyecto. Enter o una coma confirman la etiqueta escrita.
- Eliminar un proyecto elimina sus notas, pero no sus etiquetas.

## Datos de prueba

Al iniciar, la app carga:

- 3 proyectos de investigación.
- 15 notas (5 por proyecto), incluyendo 8 con descripciones de más de 600
  caracteres, una nota sin etiquetas.
- 8 etiquetas, de las cuales 7 se reutilizan en notas de proyectos distintos,
  y una etiqueta sin ninguna nota (`Ideas`).

## Capturas de pantalla

Pendientes: las capturas de las seis pantallas y del autocompletado deben
tomarse en un emulador o dispositivo Android y guardarse en una carpeta
`screenshots/` del repositorio.
