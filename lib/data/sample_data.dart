import '../models/note.dart';
import '../models/project.dart';
import '../models/tag.dart';

/// Datos de prueba que se cargan en memoria al iniciar la app.
///
/// Cumple el enunciado: 3 proyectos, 15 notas (5 por proyecto), 8 etiquetas,
/// etiquetas reutilizadas en proyectos distintos, una nota sin etiquetas,
/// una etiqueta sin notas y 8 notas con descripción de más de 600 caracteres.
class SampleData {
  const SampleData._();

  static const List<String> _paragraphs = [
    // 0
    'El objetivo de esta revisión es identificar qué herramientas de inteligencia '
        'artificial se usan hoy en las aulas universitarias y con qué propósito. Se han '
        'considerado plataformas de tutoría automática, generadores de retroalimentación '
        'y asistentes de redacción.',
    // 1
    'Los criterios de inclusión fueron publicaciones de los últimos cinco años, '
        'revisadas por pares, que reporten una experiencia real con estudiantes y no solo '
        'una propuesta teórica. Se descartaron los estudios sin grupo de control o sin '
        'medidas claras de resultado.',
    // 2
    'En la fase piloto participaron dos cursos con cuarenta estudiantes en total. Cada '
        'grupo recibió las mismas tareas, pero solo uno de ellos tuvo acceso a la '
        'retroalimentación generada automáticamente durante todo el semestre.',
    // 3
    'Las respuestas se agruparon por frecuencia y por nivel de satisfacción. Aunque la '
        'mayoría valoró positivamente la rapidez de la respuesta, varios comentaron que la '
        'retroalimentación era genérica cuando el ejercicio era abierto.',
    // 4
    'El conteo se realizó en tres estaciones de la ciudad durante dos semanas laborables '
        'y un fin de semana. Se registró la hora, el tipo de vehículo y la dirección del '
        'desplazamiento, siguiendo el protocolo de observación directa.',
    // 5
    'La afluencia de bicicletas aumentó de forma notable en los tramos con carril '
        'protegido. En cambio, en las avenidas sin separación física el uso se mantuvo '
        'estable, lo que sugiere que la infraestructura es un factor determinante.',
    // 6
    'La escala utilizada tiene buena consistencia interna según la literatura previa, '
        'aunque conviene validarla en el contexto local antes de extrapolar los resultados. '
        'Se propone una prueba piloto con una muestra independiente.',
    // 7
    'Los participantes firmaron un consentimiento informado que explica el propósito del '
        'estudio, el manejo confidencial de los datos y el derecho a retirarse en cualquier '
        'momento sin consecuencias académicas.',
    // 8
    'Las correlaciones entre horas de sueño y puntuación de estrés fueron moderadas y '
        'negativas. El análisis por subgrupos sugiere que el efecto es más fuerte en el '
        'primer año de carrera.',
    // 9
    'Queda pendiente revisar las fuentes secundarias de la segunda sección y comparar las '
        'cifras con los datos oficiales del último censo de movilidad, que se publican con '
        'retraso.',
  ];

  /// Une varios párrafos de [_paragraphs] en una descripción larga.
  static String _long(List<int> indexes) {
    return indexes.map((i) => _paragraphs[i]).join('\n\n');
  }

  static ({List<Project> projects, List<Note> notes, List<Tag> tags}) build() {
    final projects = [
      Project(
        id: 'p1',
        name: 'Inteligencia artificial en educación',
        description: 'Revisión de herramientas de IA aplicadas al aula.',
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 9, 28),
      ),
      Project(
        id: 'p2',
        name: 'Movilidad urbana sostenible',
        description: 'Transporte público y bicicletas en la ciudad.',
        createdAt: DateTime(2026, 7, 8),
        updatedAt: DateTime(2026, 9, 30),
      ),
      Project(
        id: 'p3',
        name: 'Salud mental en estudiantes',
        description: 'Encuestas, instrumentos y hallazgos sobre bienestar.',
        createdAt: DateTime(2026, 7, 15),
        updatedAt: DateTime(2026, 10, 2),
      ),
    ];

    final tags = [
      const Tag(id: 't1', name: 'Metodología', colorValue: 0xFF3949AB),
      const Tag(id: 't2', name: 'Estadística', colorValue: 0xFF00897B),
      const Tag(id: 't3', name: 'Bibliografía', colorValue: 0xFF6D4C41),
      const Tag(id: 't4', name: 'Pendiente', colorValue: 0xFFE53935),
      const Tag(id: 't5', name: 'Hipótesis', colorValue: 0xFF8E24AA),
      const Tag(id: 't6', name: 'Resultados', colorValue: 0xFF43A047),
      const Tag(id: 't7', name: 'Revisión', colorValue: 0xFFFB8C00),
      // Sin notas a propósito: comprueba que una etiqueta puede existir sola.
      const Tag(id: 't8', name: 'Ideas'),
    ];

    // Las fechas se escalonan según el índice para que el orden por
    // "última modificación" sea predecible en las pruebas.
    Note note({
      required int index,
      required String id,
      required String projectId,
      required String title,
      required String description,
      required List<String> tagIds,
    }) {
      final created = DateTime(2026, 8, 1).add(Duration(days: index * 2));
      return Note(
        id: id,
        projectId: projectId,
        title: title,
        description: description,
        createdAt: created,
        updatedAt: created.add(Duration(days: 3 + index)),
        tagIds: tagIds,
      );
    }

    final notes = [
      // Proyecto 1: Inteligencia artificial en educación
      note(
        index: 0,
        id: 'n1',
        projectId: 'p1',
        title: 'Marco teórico de la IA educativa',
        description: 'Recopilación de definiciones y modelos de uso de IA en el aula.',
        tagIds: const ['t3', 't1'],
      ),
      note(
        index: 1,
        id: 'n2',
        projectId: 'p1',
        title: 'Diseño de la encuesta docente',
        description: _long(const [0, 1, 6, 7]),
        tagIds: const ['t1', 't2'],
      ),
      note(
        index: 2,
        id: 'n3',
        projectId: 'p1',
        title: 'Hipótesis de trabajo',
        description:
            'Los estudiantes que reciben retroalimentación inmediata mejoran más en la segunda entrega.',
        tagIds: const ['t5'],
      ),
      note(
        index: 3,
        id: 'n4',
        projectId: 'p1',
        title: 'Resultados del piloto',
        description: _long(const [2, 3, 1, 9]),
        tagIds: const ['t6', 't2'],
      ),
      note(
        index: 4,
        id: 'n5',
        projectId: 'p1',
        title: 'Notas sueltas de la reunión',
        description: 'Preguntar al tutor por el tamaño de la muestra y por el permiso del centro.',
        tagIds: const [],
      ),

      // Proyecto 2: Movilidad urbana sostenible
      note(
        index: 5,
        id: 'n6',
        projectId: 'p2',
        title: 'Estado del arte del transporte',
        description: 'Resumen de políticas de movilidad sostenible en ciudades medianas.',
        tagIds: const ['t3', 't7'],
      ),
      note(
        index: 6,
        id: 'n7',
        projectId: 'p2',
        title: 'Metodología de conteo de bicicletas',
        description: _long(const [4, 5, 9, 7]),
        tagIds: const ['t1'],
      ),
      note(
        index: 7,
        id: 'n8',
        projectId: 'p2',
        title: 'Datos de afluencia',
        description: _long(const [4, 5, 9, 1]),
        tagIds: const ['t2', 't6'],
      ),
      note(
        index: 8,
        id: 'n9',
        projectId: 'p2',
        title: 'Preguntas abiertas',
        description:
            '¿Cómo influye el clima en el uso de bicicletas? ¿Hay diferencias entre fines de semana?',
        tagIds: const ['t4'],
      ),
      note(
        index: 9,
        id: 'n10',
        projectId: 'p2',
        title: 'Borrador de conclusiones',
        description: _long(const [5, 9, 3, 7]),
        tagIds: const ['t7', 't4'],
      ),

      // Proyecto 3: Salud mental en estudiantes
      note(
        index: 10,
        id: 'n11',
        projectId: 'p3',
        title: 'Instrumentos validados',
        description: _long(const [6, 1, 0, 7]),
        tagIds: const ['t1', 't3'],
      ),
      note(
        index: 11,
        id: 'n12',
        projectId: 'p3',
        title: 'Análisis preliminar',
        description: _long(const [8, 2, 3, 9]),
        tagIds: const ['t2', 't6'],
      ),
      note(
        index: 12,
        id: 'n13',
        projectId: 'p3',
        title: 'Consideraciones éticas',
        description: _long(const [7, 1, 6, 8]),
        tagIds: const ['t4'],
      ),
      note(
        index: 13,
        id: 'n14',
        projectId: 'p3',
        title: 'Hipótesis sobre sueño y estrés',
        description:
            'Dormir menos de seis horas se asocia con mayor estrés percibido en el primer año.',
        tagIds: const ['t5', 't7'],
      ),
      note(
        index: 14,
        id: 'n15',
        projectId: 'p3',
        title: 'Referencias por revisar',
        description:
            'Revisar tres artículos sobre validación de escalas de bienestar antes de la entrega.',
        tagIds: const ['t3', 't4'],
      ),
    ];

    return (projects: projects, notes: notes, tags: tags);
  }
}
