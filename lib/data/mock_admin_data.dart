// Datos simulados para el Panel Admin de GreenNode (vista "Dashboard").

// ─── Métricas (4 tarjetas) ────────────────────────────────────────────────────

class MetricasDashboard {
  final int cotizacionesPendientes;
  final int proyectosEnProgreso;
  final int proyectosCompletados;
  final int proyectosCancelados;

  const MetricasDashboard({
    required this.cotizacionesPendientes,
    required this.proyectosEnProgreso,
    required this.proyectosCompletados,
    required this.proyectosCancelados,
  });
}

const mockMetricas = MetricasDashboard(
  cotizacionesPendientes: 14,
  proyectosEnProgreso: 27,
  proyectosCompletados: 52,
  proyectosCancelados: 6,
);

// ─── Últimos proyectos ─────────────────────────────────────────────────────────

enum EstadoProyectoAdmin { enProgreso, completado, cancelado }

class ProyectoAdminItem {
  final String id;
  final String nombre;
  final String empresa;
  final EstadoProyectoAdmin estado;
  final double avance;

  const ProyectoAdminItem({
    required this.id,
    required this.nombre,
    required this.empresa,
    required this.estado,
    required this.avance,
  });
}

const mockProyectosRecientes = [
  ProyectoAdminItem(
    id: 'proy-101',
    nombre: 'Bosque Constructora Verde',
    empresa: 'Constructora Verde S.A.',
    estado: EstadoProyectoAdmin.enProgreso,
    avance: 0.45,
  ),
  ProyectoAdminItem(
    id: 'proy-102',
    nombre: 'Reforestación Lácteos del Valle',
    empresa: 'Lácteos del Valle',
    estado: EstadoProyectoAdmin.enProgreso,
    avance: 0.62,
  ),
  ProyectoAdminItem(
    id: 'proy-103',
    nombre: 'Bosque Andino Textiles Norte',
    empresa: 'Textiles Norte',
    estado: EstadoProyectoAdmin.completado,
    avance: 1.0,
  ),
  ProyectoAdminItem(
    id: 'proy-104',
    nombre: 'Cuenca Verde Banco Andino',
    empresa: 'Banco Andino',
    estado: EstadoProyectoAdmin.enProgreso,
    avance: 0.18,
  ),
  ProyectoAdminItem(
    id: 'proy-105',
    nombre: 'Reserva El Roble Hidroeléctrica',
    empresa: 'Hidroeléctrica del Sur',
    estado: EstadoProyectoAdmin.completado,
    avance: 1.0,
  ),
  ProyectoAdminItem(
    id: 'proy-106',
    nombre: 'Páramo Sur Minería Responsable',
    empresa: 'Minería Responsable Ltda.',
    estado: EstadoProyectoAdmin.cancelado,
    avance: 0.08,
  ),
  ProyectoAdminItem(
    id: 'proy-107',
    nombre: 'Bosque Mixto Avícola Central',
    empresa: 'Avícola Central',
    estado: EstadoProyectoAdmin.enProgreso,
    avance: 0.73,
  ),
  ProyectoAdminItem(
    id: 'proy-108',
    nombre: 'Corredor Verde Plásticos del Caribe',
    empresa: 'Plásticos del Caribe',
    estado: EstadoProyectoAdmin.cancelado,
    avance: 0.22,
  ),
];

// ─── Evolución mensual (gráfica de barras) ────────────────────────────────────

class EvolucionMensual {
  final String mes;
  final int enProgreso;
  final int completado;
  final int cancelado;

  const EvolucionMensual({
    required this.mes,
    required this.enProgreso,
    required this.completado,
    required this.cancelado,
  });
}

const mockEvolucionMensual = [
  EvolucionMensual(mes: 'Ene', enProgreso: 14, completado: 6, cancelado: 1),
  EvolucionMensual(mes: 'Feb', enProgreso: 17, completado: 9, cancelado: 2),
  EvolucionMensual(mes: 'Mar', enProgreso: 19, completado: 12, cancelado: 1),
  EvolucionMensual(mes: 'Abr', enProgreso: 21, completado: 15, cancelado: 3),
  EvolucionMensual(mes: 'May', enProgreso: 24, completado: 19, cancelado: 2),
  EvolucionMensual(mes: 'Jun', enProgreso: 27, completado: 24, cancelado: 3),
];

// ─── Acciones prioritarias ──────────────────────────────────────────────────────

class CotizacionPendienteItem {
  final String empresa;
  final String fecha;

  const CotizacionPendienteItem({required this.empresa, required this.fecha});
}

class ProyectoSinEvidenciaItem {
  final String nombre;
  final int diasSinEvidencia;

  const ProyectoSinEvidenciaItem({
    required this.nombre,
    required this.diasSinEvidencia,
  });
}

class AccionesPrioritarias {
  final List<CotizacionPendienteItem> cotizacionesPendientes;
  final List<ProyectoSinEvidenciaItem> proyectosSinEvidencia;

  const AccionesPrioritarias({
    required this.cotizacionesPendientes,
    required this.proyectosSinEvidencia,
  });
}

const mockAccionesPrioritarias = AccionesPrioritarias(
  cotizacionesPendientes: [
    CotizacionPendienteItem(empresa: 'Constructora Verde S.A.', fecha: '24 jun 2026'),
    CotizacionPendienteItem(empresa: 'Lácteos del Valle', fecha: '23 jun 2026'),
    CotizacionPendienteItem(empresa: 'Textiles Norte', fecha: '21 jun 2026'),
    CotizacionPendienteItem(empresa: 'Banco Andino', fecha: '19 jun 2026'),
  ],
  proyectosSinEvidencia: [
    ProyectoSinEvidenciaItem(nombre: 'Páramo Sur · Minería Responsable', diasSinEvidencia: 38),
    ProyectoSinEvidenciaItem(nombre: 'Cuenca Verde · Banco Andino', diasSinEvidencia: 22),
    ProyectoSinEvidenciaItem(nombre: 'Bosque Mixto · Avícola Central', diasSinEvidencia: 14),
  ],
);

// ─── Cotizaciones Admin ────────────────────────────────────────────────────────

enum EstadoCotizacionAdmin { pendiente, enRevision }

class CotizacionAdminItem {
  final String id;
  final String empresa;
  final String territorio;
  final int arboles;
  final String fecha;
  final EstadoCotizacionAdmin estado;
  final String propuestaIA;

  const CotizacionAdminItem({
    required this.id,
    required this.empresa,
    required this.territorio,
    required this.arboles,
    required this.fecha,
    required this.estado,
    required this.propuestaIA,
  });
}

const mockCotizacionesAdmin = [
  CotizacionAdminItem(
    id: 'COT-A-001',
    empresa: 'Constructora Verde S.A.',
    territorio: 'Área de Vida Medellín Norte',
    arboles: 500,
    fecha: '24 jun 2026',
    estado: EstadoCotizacionAdmin.pendiente,
    propuestaIA:
        'Se recomienda un proyecto de bosque nativo de 500 árboles en el Área de Vida Medellín Norte, zona Andina. '
        'Las especies sugeridas son Nogal cafetero (Cordia alliodora) y Cedro negro (Juglans neotropica), ambas certificadas ICA y adaptadas al gradiente altitudinal de la región. '
        'El impacto estimado es de 11 toneladas de CO₂ capturado por año al alcanzar madurez. '
        'Se propone un período de ejecución de 24 meses con seguimiento trimestral y validación de evidencias por IA.',
  ),
  CotizacionAdminItem(
    id: 'COT-A-002',
    empresa: 'Lácteos del Valle',
    territorio: 'Montes de María, Bolívar',
    arboles: 1200,
    fecha: '23 jun 2026',
    estado: EstadoCotizacionAdmin.pendiente,
    propuestaIA:
        'Para Lácteos del Valle se propone un corredor biológico de 1 200 árboles en los Montes de María, Bolívar, Zona Caribe. '
        'Se priorizan especies como Trupillo (Prosopis juliflora) y Caracolí (Anacardium excelsum), tolerantes a la estacionalidad hídrica de la región. '
        'El proyecto contribuiría a reducir la erosión hídrica en cuencas abastecedoras de la planta de procesamiento de la empresa. '
        'Impacto estimado: 26.4 t CO₂/año. Plazo de ejecución recomendado: 30 meses.',
  ),
  CotizacionAdminItem(
    id: 'COT-A-003',
    empresa: 'Banco Andino',
    territorio: 'Bajo Caquetá, Caquetá',
    arboles: 3000,
    fecha: '19 jun 2026',
    estado: EstadoCotizacionAdmin.enRevision,
    propuestaIA:
        'Banco Andino solicita un proyecto de alta escala con 3 000 árboles en la Zona Amazónica del Bajo Caquetá. '
        'Se recomienda una mezcla de Abarco (Cariniana pyriformis) y Cedro rosado (Cedrela odorata), especies de alto valor ecológico y comercial, con ciclo de vida largo. '
        'Este proyecto posiciona a Banco Andino como líder en compensación de carbono del sector financiero colombiano, con una captura estimada de 66 t CO₂/año. '
        'Se requiere alianza con comunidad local para custodia del territorio; GreenNode puede gestionar el convenio.',
  ),
  CotizacionAdminItem(
    id: 'COT-A-004',
    empresa: 'Textiles Norte',
    territorio: 'Área de Vida Medellín Norte',
    arboles: 250,
    fecha: '21 jun 2026',
    estado: EstadoCotizacionAdmin.pendiente,
    propuestaIA:
        'Textiles Norte cumple el mínimo legal de la Ley 2173 con 250 árboles para sus 120 empleados registrados. '
        'Se sugiere el lote disponible en el Área de Vida Medellín Norte con especies Yarumo (Cecropia peltata) y Roble (Quercus humboldtii), de rápido establecimiento. '
        'Impacto estimado: 5.5 t CO₂/año. '
        'Se recomienda incluir mantenimiento por 3 años para garantizar la supervivencia mínima del 80% exigida por la normativa.',
  ),
  CotizacionAdminItem(
    id: 'COT-A-005',
    empresa: 'Hidroeléctrica del Sur',
    territorio: 'Montes de María, Bolívar',
    arboles: 800,
    fecha: '18 jun 2026',
    estado: EstadoCotizacionAdmin.enRevision,
    propuestaIA:
        'Hidroeléctrica del Sur requiere un proyecto de restauración riparia de 800 árboles en los Montes de María para compensar el impacto hídrico de su concesión. '
        'Se priorizan Dividivi (Libidibia coriaria) y Caracolí (Anacardium excelsum) por su aporte a la regulación de caudales y control de sedimentos. '
        'El proyecto se alinea con los compromisos de la licencia ambiental vigente y puede emitirse certificado en 18 meses. '
        'Captura estimada: 17.6 t CO₂/año.',
  ),
  CotizacionAdminItem(
    id: 'COT-A-006',
    empresa: 'Avícola Central',
    territorio: 'Bajo Caquetá, Caquetá',
    arboles: 600,
    fecha: '17 jun 2026',
    estado: EstadoCotizacionAdmin.pendiente,
    propuestaIA:
        'Avícola Central opta por un proyecto amazónico de 600 árboles para neutralizar su huella de carbono operativa. '
        'Se recomienda Canangucho (Mauritia flexuosa) y Abarco (Cariniana pyriformis), con alta capacidad de secuestro de carbono en suelos húmedos amazónicos. '
        'El lote propuesto en el Bajo Caquetá garantiza conectividad con reservas naturales vecinas, aumentando el valor ecosistémico del proyecto. '
        'Impacto estimado: 13.2 t CO₂/año en régimen de madurez.',
  ),
];
