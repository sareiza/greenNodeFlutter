// Modelos y datos simulados para GreenNode mientras no existe un backend real.

// ─── Mis cotizaciones (sección "4. Mis cotizaciones") ────────────────────────

class CotizacionListaItem {
  final String id;
  final String fecha;
  final String tipo;
  final int arboles;
  final int monto;
  final EstadoCotizacion estado;

  const CotizacionListaItem({
    required this.id,
    required this.fecha,
    required this.tipo,
    required this.arboles,
    required this.monto,
    required this.estado,
  });

  String get montoDisplay {
    if (monto >= 1000) {
      final miles = monto ~/ 1000;
      final resto = (monto % 1000).toString().padLeft(3, '0');
      return '\$$miles,$resto';
    }
    return '\$$monto';
  }

  String get meta => '$fecha · $tipo · $arboles árboles';
}

// ─────────────────────────────────────────────────────────────────────────────

// ─── Proyecto overview (sección "3. Mi proyecto") ────────────────────────────

enum TipoArbol { broad, conical, palm }

enum EstadoHitoTimeline { done, current, locked }

class EspecieSembrada {
  final String nombre;
  final String nombreCientifico;
  final int cantidad;
  final int totalProyecto;
  final TipoArbol tipoArbol;

  const EspecieSembrada({
    required this.nombre,
    required this.nombreCientifico,
    required this.cantidad,
    required this.totalProyecto,
    required this.tipoArbol,
  });
}

class HitoTimeline {
  final String mes;
  final String titulo;
  final EstadoHitoTimeline estado;

  const HitoTimeline({
    required this.mes,
    required this.titulo,
    required this.estado,
  });
}

const mockEspeciesSembradas = [
  EspecieSembrada(
    nombre: 'Nogal cafetero',
    nombreCientifico: 'Cordia alliodora',
    cantidad: 40,
    totalProyecto: 100,
    tipoArbol: TipoArbol.broad,
  ),
  EspecieSembrada(
    nombre: 'Cedro negro',
    nombreCientifico: 'Juglans neotropica',
    cantidad: 30,
    totalProyecto: 100,
    tipoArbol: TipoArbol.conical,
  ),
  EspecieSembrada(
    nombre: 'Yarumo',
    nombreCientifico: 'Cecropia peltata',
    cantidad: 20,
    totalProyecto: 100,
    tipoArbol: TipoArbol.broad,
  ),
  EspecieSembrada(
    nombre: 'Roble',
    nombreCientifico: 'Quercus humboldtii',
    cantidad: 10,
    totalProyecto: 100,
    tipoArbol: TipoArbol.conical,
  ),
];

const mockHitosTimeline = [
  HitoTimeline(
    mes: 'Mes 0',
    titulo: 'Establecimiento del lote',
    estado: EstadoHitoTimeline.done,
  ),
  HitoTimeline(
    mes: 'Mes 3',
    titulo: 'Primera evidencia de crecimiento',
    estado: EstadoHitoTimeline.done,
  ),
  HitoTimeline(
    mes: 'Mes 6',
    titulo: 'Medición de crecimiento',
    estado: EstadoHitoTimeline.current,
  ),
  HitoTimeline(
    mes: 'Mes 12',
    titulo: 'Seguimiento anual',
    estado: EstadoHitoTimeline.locked,
  ),
  HitoTimeline(
    mes: 'Mes 18',
    titulo: 'Validación intermedia',
    estado: EstadoHitoTimeline.locked,
  ),
  HitoTimeline(
    mes: 'Mes 24',
    titulo: 'Cierre y emisión de certificado',
    estado: EstadoHitoTimeline.locked,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class Empresa {
  final String id;
  final String nombre;
  final String rubro;
  final String ruc;
  final String direccion;
  final String telefono;
  final String email;
  final String logoUrl;
  final String descripcion;

  const Empresa({
    required this.id,
    required this.nombre,
    required this.rubro,
    required this.ruc,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.logoUrl,
    required this.descripcion,
  });
}

enum EstadoCotizacion { pendiente, enRevision, aprobada, rechazada }

class Especie {
  final String id;
  final String nombre;
  final String nombreCientifico;
  final String zona;
  final int tiempoCrecimientoAnios;
  final double capturaCarbonoTonAnio;
  final double precioPorArbol;
  final String imagenUrl;

  const Especie({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.zona,
    required this.tiempoCrecimientoAnios,
    required this.capturaCarbonoTonAnio,
    required this.precioPorArbol,
    required this.imagenUrl,
  });
}

class Cotizacion {
  final String id;
  final String empresaId;
  final DateTime fecha;
  final EstadoCotizacion estado;
  final String zona;
  final List<String> especiesIds;
  final int cantidadArboles;
  final double areaHectareas;
  final double montoTotal;
  final String detalle;

  const Cotizacion({
    required this.id,
    required this.empresaId,
    required this.fecha,
    required this.estado,
    required this.zona,
    required this.especiesIds,
    required this.cantidadArboles,
    required this.areaHectareas,
    required this.montoTotal,
    required this.detalle,
  });
}

class Hito {
  final String id;
  final String nombre;
  final String descripcion;
  final DateTime fecha;
  final bool completado;

  const Hito({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.completado,
  });
}

class Evidencia {
  final String id;
  final String url;
  final DateTime fecha;
  final String descripcion;

  const Evidencia({
    required this.id,
    required this.url,
    required this.fecha,
    required this.descripcion,
  });
}

enum EstadoProyecto { planificacion, enEjecucion, completado, pausado }

class Proyecto {
  final String id;
  final String cotizacionId;
  final String nombre;
  final EstadoProyecto estado;
  final DateTime fechaInicio;
  final DateTime? fechaFinEstimada;
  final String zona;
  final double avancePorcentaje;
  final List<Hito> hitos;
  final List<Evidencia> evidencias;

  const Proyecto({
    required this.id,
    required this.cotizacionId,
    required this.nombre,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFinEstimada,
    required this.zona,
    required this.avancePorcentaje,
    required this.hitos,
    required this.evidencias,
  });
}

class Territorio {
  final String id;
  final String nombre;
  final String region;
  final String pais;
  final double areaDisponibleHectareas;
  final List<String> especiesDisponiblesIds;
  final String descripcion;
  final String imagenUrl;

  const Territorio({
    required this.id,
    required this.nombre,
    required this.region,
    required this.pais,
    required this.areaDisponibleHectareas,
    required this.especiesDisponiblesIds,
    required this.descripcion,
    required this.imagenUrl,
  });
}

class ArticuloLegal {
  final String id;
  final String titulo;
  final String numeroNorma;
  final String descripcion;
  final String categoria;

  const ArticuloLegal({
    required this.id,
    required this.titulo,
    required this.numeroNorma,
    required this.descripcion,
    required this.categoria,
  });
}

class MarcoLegal {
  final String id;
  final String titulo;
  final String resumen;
  final List<ArticuloLegal> articulos;

  const MarcoLegal({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.articulos,
  });
}

final mockEmpresa = const Empresa(
  id: 'emp-001',
  nombre: 'GreenNode S.A.C.',
  rubro: 'Reforestación y Créditos de Carbono',
  ruc: '20601234567',
  direccion: 'Av. La Molina 1234, Lima, Perú',
  telefono: '+51 987 654 321',
  email: 'contacto@greennode.com',
  logoUrl: 'assets/images/greennode_logo.png',
  descripcion:
      'GreenNode conecta empresas con proyectos de reforestación y '
      'compensación de carbono verificados, generando impacto ambiental '
      'medible y trazable.',
);

final mockEspecies = const [
  Especie(
    id: 'esp-001',
    nombre: 'Bolaina blanca',
    nombreCientifico: 'Guazuma crinita',
    zona: 'Amazonía',
    tiempoCrecimientoAnios: 5,
    capturaCarbonoTonAnio: 8.2,
    precioPorArbol: 12.5,
    imagenUrl: 'assets/images/especies/bolaina.png',
  ),
  Especie(
    id: 'esp-002',
    nombre: 'Capirona',
    nombreCientifico: 'Calycophyllum spruceanum',
    zona: 'Amazonía',
    tiempoCrecimientoAnios: 8,
    capturaCarbonoTonAnio: 10.4,
    precioPorArbol: 15.0,
    imagenUrl: 'assets/images/especies/capirona.png',
  ),
  Especie(
    id: 'esp-003',
    nombre: 'Quinual',
    nombreCientifico: 'Polylepis racemosa',
    zona: 'Sierra',
    tiempoCrecimientoAnios: 10,
    capturaCarbonoTonAnio: 6.7,
    precioPorArbol: 18.0,
    imagenUrl: 'assets/images/especies/quinual.png',
  ),
  Especie(
    id: 'esp-004',
    nombre: 'Tara',
    nombreCientifico: 'Caesalpinia spinosa',
    zona: 'Sierra',
    tiempoCrecimientoAnios: 6,
    capturaCarbonoTonAnio: 5.9,
    precioPorArbol: 14.0,
    imagenUrl: 'assets/images/especies/tara.png',
  ),
  Especie(
    id: 'esp-005',
    nombre: 'Algarrobo',
    nombreCientifico: 'Prosopis pallida',
    zona: 'Costa',
    tiempoCrecimientoAnios: 7,
    capturaCarbonoTonAnio: 7.1,
    precioPorArbol: 13.2,
    imagenUrl: 'assets/images/especies/algarrobo.png',
  ),
  Especie(
    id: 'esp-006',
    nombre: 'Huarango',
    nombreCientifico: 'Prosopis limensis',
    zona: 'Costa',
    tiempoCrecimientoAnios: 9,
    capturaCarbonoTonAnio: 6.3,
    precioPorArbol: 16.5,
    imagenUrl: 'assets/images/especies/huarango.png',
  ),
];

final mockTerritorios = const [
  Territorio(
    id: 'ter-001',
    nombre: 'Bosque San Martín',
    region: 'San Martín',
    pais: 'Perú',
    areaDisponibleHectareas: 320.5,
    especiesDisponiblesIds: ['esp-001', 'esp-002'],
    descripcion:
        'Zona amazónica con suelos óptimos para especies de rápido '
        'crecimiento y alta captura de carbono.',
    imagenUrl: 'assets/images/territorios/san_martin.png',
  ),
  Territorio(
    id: 'ter-002',
    nombre: 'Valle del Mantaro',
    region: 'Junín',
    pais: 'Perú',
    areaDisponibleHectareas: 145.0,
    especiesDisponiblesIds: ['esp-003', 'esp-004'],
    descripcion:
        'Territorio andino destinado a la restauración de ecosistemas '
        'de altura y conservación de cuencas hídricas.',
    imagenUrl: 'assets/images/territorios/mantaro.png',
  ),
  Territorio(
    id: 'ter-003',
    nombre: 'Desierto Verde Ica',
    region: 'Ica',
    pais: 'Perú',
    areaDisponibleHectareas: 210.8,
    especiesDisponiblesIds: ['esp-005', 'esp-006'],
    descripcion:
        'Proyecto de forestación en zonas costeras áridas con especies '
        'nativas resistentes a la sequía.',
    imagenUrl: 'assets/images/territorios/ica.png',
  ),
];

final mockCotizaciones = [
  Cotizacion(
    id: 'cot-1001',
    empresaId: 'emp-001',
    fecha: DateTime(2026, 4, 12),
    estado: EstadoCotizacion.aprobada,
    zona: 'Amazonía',
    especiesIds: const ['esp-001', 'esp-002'],
    cantidadArboles: 5000,
    areaHectareas: 12.5,
    montoTotal: 68750.0,
    detalle:
        'Reforestación de bolaina blanca y capirona para compensación de '
        'huella de carbono corporativa anual.',
  ),
  Cotizacion(
    id: 'cot-1002',
    empresaId: 'emp-001',
    fecha: DateTime(2026, 5, 3),
    estado: EstadoCotizacion.enRevision,
    zona: 'Sierra',
    especiesIds: const ['esp-003', 'esp-004'],
    cantidadArboles: 1800,
    areaHectareas: 6.2,
    montoTotal: 28800.0,
    detalle:
        'Restauración de microcuenca andina con quinual y tara como parte '
        'de programa de responsabilidad social.',
  ),
  Cotizacion(
    id: 'cot-1003',
    empresaId: 'emp-001',
    fecha: DateTime(2026, 5, 20),
    estado: EstadoCotizacion.pendiente,
    zona: 'Costa',
    especiesIds: const ['esp-005', 'esp-006'],
    cantidadArboles: 3200,
    areaHectareas: 9.0,
    montoTotal: 45120.0,
    detalle:
        'Forestación costera con algarrobo y huarango para mitigar '
        'erosión de suelos en zona desértica.',
  ),
  Cotizacion(
    id: 'cot-1004',
    empresaId: 'emp-001',
    fecha: DateTime(2026, 6, 8),
    estado: EstadoCotizacion.rechazada,
    zona: 'Amazonía',
    especiesIds: const ['esp-002'],
    cantidadArboles: 900,
    areaHectareas: 2.1,
    montoTotal: 13500.0,
    detalle:
        'Solicitud rechazada por superposición con área de concesión '
        'forestal existente.',
  ),
];

final mockProyecto = Proyecto(
  id: 'proy-001',
  cotizacionId: 'cot-1001',
  nombre: 'Reforestación Bosque San Martín',
  estado: EstadoProyecto.enEjecucion,
  fechaInicio: DateTime(2026, 4, 20),
  fechaFinEstimada: DateTime(2027, 4, 20),
  zona: 'Amazonía',
  avancePorcentaje: 42.0,
  hitos: [
    Hito(
      id: 'hito-01',
      nombre: 'Preparación de terreno',
      descripcion: 'Limpieza y demarcación de las 12.5 hectáreas asignadas.',
      fecha: DateTime(2026, 4, 25),
      completado: true,
    ),
    Hito(
      id: 'hito-02',
      nombre: 'Siembra inicial',
      descripcion: 'Plantación de los primeros 2,000 plantones.',
      fecha: DateTime(2026, 5, 15),
      completado: true,
    ),
    Hito(
      id: 'hito-03',
      nombre: 'Monitoreo de crecimiento',
      descripcion: 'Primera evaluación de supervivencia y crecimiento.',
      fecha: DateTime(2026, 7, 10),
      completado: false,
    ),
    Hito(
      id: 'hito-04',
      nombre: 'Certificación de carbono',
      descripcion: 'Auditoría externa para certificación de créditos.',
      fecha: DateTime(2027, 1, 15),
      completado: false,
    ),
  ],
  evidencias: [
    Evidencia(
      id: 'evi-01',
      url: 'assets/images/evidencias/terreno_preparado.png',
      fecha: DateTime(2026, 4, 26),
      descripcion: 'Terreno listo para siembra.',
    ),
    Evidencia(
      id: 'evi-02',
      url: 'assets/images/evidencias/siembra_inicial.png',
      fecha: DateTime(2026, 5, 16),
      descripcion: 'Plantones recién sembrados en parcela 1.',
    ),
  ],
);

final mockMarcoLegal = const MarcoLegal(
  id: 'legal-001',
  titulo: 'Marco Legal de Reforestación y Créditos de Carbono',
  resumen:
      'Conjunto de normas peruanas que regulan las actividades de '
      'reforestación, conservación de bosques y comercialización de '
      'créditos de carbono.',
  articulos: [
    ArticuloLegal(
      id: 'art-01',
      titulo: 'Ley Forestal y de Fauna Silvestre',
      numeroNorma: 'Ley N.º 29763',
      descripcion:
          'Regula la gestión sostenible de los recursos forestales y de '
          'fauna silvestre en el territorio nacional.',
      categoria: 'Forestal',
    ),
    ArticuloLegal(
      id: 'art-02',
      titulo: 'Reglamento de Gestión Forestal',
      numeroNorma: 'D.S. N.º 018-2015-MINAGRI',
      descripcion:
          'Establece los procedimientos para el otorgamiento de derechos '
          'forestales y planes de manejo.',
      categoria: 'Forestal',
    ),
    ArticuloLegal(
      id: 'art-03',
      titulo: 'Marco Regulatorio del Mercado de Carbono',
      numeroNorma: 'D.S. N.º 013-2022-MINAM',
      descripcion:
          'Define las reglas para la creación, registro y transferencia '
          'de créditos de carbono en el Perú.',
      categoria: 'Ambiental',
    ),
    ArticuloLegal(
      id: 'art-04',
      titulo: 'Ley Marco sobre Cambio Climático',
      numeroNorma: 'Ley N.º 30754',
      descripcion:
          'Establece los principios y lineamientos para la gestión '
          'integral del cambio climático en el país.',
      categoria: 'Ambiental',
    ),
  ],
);

// ─── Galería de evidencias (sección "5. Galería de evidencias") ──────────────

enum EstadoEvidencia { aprobado, pendiente, rechazado }

enum EstadoEspecieDeteccion { ok, pending, none }

class EvidenciaItem {
  final String caption;
  final EstadoEvidencia estado;
  final String aiTexto;
  final String especie;
  final EstadoEspecieDeteccion estadoEspecie;

  const EvidenciaItem({
    required this.caption,
    required this.estado,
    required this.aiTexto,
    required this.especie,
    required this.estadoEspecie,
  });
}

const mockEvidencias = [
  EvidenciaItem(
    caption: 'Mes 0 · Establecimiento',
    estado: EstadoEvidencia.aprobado,
    aiTexto: 'IA 98% · Validada',
    especie: 'Nogal cafetero',
    estadoEspecie: EstadoEspecieDeteccion.ok,
  ),
  EvidenciaItem(
    caption: 'Mes 3 · Crecimiento',
    estado: EstadoEvidencia.aprobado,
    aiTexto: 'IA 95% · Validada',
    especie: 'Cedro negro',
    estadoEspecie: EstadoEspecieDeteccion.ok,
  ),
  EvidenciaItem(
    caption: 'Mes 6 · Medición',
    estado: EstadoEvidencia.pendiente,
    aiTexto: 'En análisis…',
    especie: 'Detectando especie…',
    estadoEspecie: EstadoEspecieDeteccion.pending,
  ),
  EvidenciaItem(
    caption: 'Mes 6 · Lote B',
    estado: EstadoEvidencia.rechazado,
    aiTexto: 'No coincide GPS',
    especie: 'Sin coincidencia',
    estadoEspecie: EstadoEspecieDeteccion.none,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

const mockCotizacionesLista = [
  CotizacionListaItem(
    id: 'COT-2024-018',
    fecha: '12 mar 2024',
    tipo: 'Bosque nativo',
    arboles: 100,
    monto: 450,
    estado: EstadoCotizacion.aprobada,
  ),
  CotizacionListaItem(
    id: 'COT-2024-022',
    fecha: '28 mar 2024',
    tipo: 'Mixto',
    arboles: 250,
    monto: 1407,
    estado: EstadoCotizacion.enRevision,
  ),
  CotizacionListaItem(
    id: 'COT-2024-009',
    fecha: '05 mar 2024',
    tipo: 'Premium',
    arboles: 60,
    monto: 432,
    estado: EstadoCotizacion.rechazada,
  ),
];

// ─── Áreas de siembra (sección "7. Áreas de siembra") ─────────────────────────

class LoteSiembra {
  final String nombre;
  final String region;
  final double lat;
  final double lng;
  final int plantados;
  final int total;
  final EstadoCotizacion estado;

  const LoteSiembra({
    required this.nombre,
    required this.region,
    required this.lat,
    required this.lng,
    required this.plantados,
    required this.total,
    required this.estado,
  });

  double get porcentaje => total == 0 ? 0 : plantados / total;
}

const mockLotesSiembra = [
  LoteSiembra(
    nombre: 'Reserva El Roble',
    region: 'Antioquia',
    lat: 6.2442,
    lng: -75.5812,
    plantados: 2480,
    total: 5000,
    estado: EstadoCotizacion.aprobada,
  ),
  LoteSiembra(
    nombre: 'Cuenca del Río Verde',
    region: 'Caldas',
    lat: 5.0689,
    lng: -75.5174,
    plantados: 900,
    total: 3000,
    estado: EstadoCotizacion.enRevision,
  ),
  LoteSiembra(
    nombre: 'Altos de Niebla',
    region: 'Risaralda',
    lat: 4.8133,
    lng: -75.6961,
    plantados: 0,
    total: 2000,
    estado: EstadoCotizacion.pendiente,
  ),
  LoteSiembra(
    nombre: 'Cañón del Cauca',
    region: 'Antioquia',
    lat: 6.5440,
    lng: -75.8267,
    plantados: 1500,
    total: 1500,
    estado: EstadoCotizacion.aprobada,
  ),
  LoteSiembra(
    nombre: 'Páramo Sur',
    region: 'Tolima',
    lat: 4.4389,
    lng: -75.2322,
    plantados: 200,
    total: 4000,
    estado: EstadoCotizacion.rechazada,
  ),
];
