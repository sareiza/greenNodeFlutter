import 'package:flutter/foundation.dart';

import '../../../data/api_service.dart';
import '../../../data/mock_data.dart'; // EspecieSembrada, HitoTimeline, TipoArbol

// ─── Helpers de fecha ─────────────────────────────────────────────────────────

DateTime _addMonths(DateTime d, int m) => DateTime(d.year, d.month + m, d.day);

String _fmtYear(DateTime d) => d.year.toString();

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try { return DateTime.parse(v.toString()); } catch (_) { return null; }
}

// ─── Hitos calculados desde fechaInicio ──────────────────────────────────────

/// Genera los 6 hitos estándar de un proyecto a partir de [inicio].
/// Exportada para que [proyecto_seguimiento_screen] pueda reutilizarla.
List<HitoTimeline> calcularHitosDesde(DateTime inicio) {
  final now = DateTime.now();

  const defs = [
    (0,  'Establecimiento del lote'),
    (3,  'Primera evidencia de crecimiento'),
    (6,  'Medición de crecimiento'),
    (12, 'Seguimiento anual'),
    (18, 'Validación intermedia'),
    (24, 'Cierre y emisión de certificado'),
  ];

  bool foundCurrent = false;

  return [
    for (final (m, titulo) in defs)
      () {
        final fecha = _addMonths(inicio, m);
        final EstadoHitoTimeline estado;
        if (fecha.isBefore(now)) {
          estado = EstadoHitoTimeline.done;
        } else if (!foundCurrent) {
          foundCurrent = true;
          estado = EstadoHitoTimeline.current;
        } else {
          estado = EstadoHitoTimeline.locked;
        }
        return HitoTimeline(mes: 'Mes $m', titulo: titulo, estado: estado);
      }(),
  ];
}

// ─── Datos de hito con fecha (para mini-cards) ────────────────────────────────

typedef _HitoDato = ({int meses, String titulo, DateTime fecha});

List<_HitoDato> _hitoDatos(DateTime inicio) {
  const defs = [
    (0,  'Establecimiento del lote'),
    (3,  'Primera evidencia de crecimiento'),
    (6,  'Medición de crecimiento'),
    (12, 'Seguimiento anual'),
    (18, 'Validación intermedia'),
    (24, 'Cierre y emisión de certificado'),
  ];
  return [
    for (final (m, titulo) in defs)
      (meses: m, titulo: titulo, fecha: _addMonths(inicio, m)),
  ];
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class ProyectoProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  bool hasProject = false;

  // ── Datos del API ─────────────────────────────────────────────────────────
  String nombre     = '';
  String status     = '';
  double avance     = 0.0;
  String territory  = '';
  int totalArboles  = 0;
  DateTime? fechaInicio;
  DateTime? fechaFin;

  // ── Derived strings para la UI ────────────────────────────────────────────
  String get periodo {
    if (fechaInicio == null) return '—';
    final ini = _fmtYear(fechaInicio!);
    final fin = fechaFin != null ? _fmtYear(fechaFin!) : '—';
    return 'Período $ini–$fin';
  }
  String get area => territory.isNotEmpty ? territory : '—';

  // ── Mini-cards (computadas) ───────────────────────────────────────────────
  String hitoActualValor   = '—';
  String hitoActualDetalle = '—';
  String proximoHitoValor  = '—';
  String proximoHitoDetalle = '—';
  String arbolesVivosValor  = '—';
  String arbolesVivosDetalle = '—';

  // ── Especies (mock escalado al total real) ────────────────────────────────
  List<EspecieSembrada> get especies {
    if (totalArboles == 0) return List.of(mockEspeciesSembradas);
    final totalMock =
        mockEspeciesSembradas.fold(0, (s, e) => s + e.cantidad);
    return mockEspeciesSembradas.map((e) => EspecieSembrada(
          nombre:          e.nombre,
          nombreCientifico: e.nombreCientifico,
          tipoArbol:       e.tipoArbol,
          totalProyecto:   totalArboles,
          cantidad:        (totalArboles * e.cantidad / totalMock).round(),
        )).toList();
  }

  // ── Hitos (calculados con fechaInicio real) ───────────────────────────────
  List<HitoTimeline> get hitos =>
      fechaInicio != null
          ? calcularHitosDesde(fechaInicio!)
          : List.of(mockHitosTimeline);

  // ── Carga ─────────────────────────────────────────────────────────────────

  Future<void> cargar() async {
    isLoading = true;
    error     = null;
    notifyListeners();

    try {
      final raw = await apiService.getProyectos();

      if (raw.isEmpty) {
        hasProject = false;
      } else {
        final data = raw.first as Map<String, dynamic>;
        _mapDatos(data);
        hasProject = true;
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _mapDatos(Map<String, dynamic> data) {
    nombre       = data['name']?.toString() ?? data['nombre']?.toString() ?? 'Mi proyecto';
    status       = (data['status']?.toString() ?? 'active').toLowerCase();
    avance       = (data['progress'] as num?)?.toDouble() ?? 0.0;
    territory    = data['territory']?.toString() ??
                   data['area']?.toString() ??
                   data['region']?.toString() ?? '';
    totalArboles = (data['trees'] as num?)?.toInt() ??
                   (data['numberOfTrees'] as num?)?.toInt() ??
                   (data['treeQuantity'] as num?)?.toInt() ?? 0;
    fechaInicio  = _parseDate(data['startDate'] ?? data['createdAt']);
    fechaFin     = _parseDate(data['endDate'] ?? data['estimatedEndDate'] ?? data['finishDate']);

    _computarMiniCards();
  }

  void _computarMiniCards() {
    final inicio = fechaInicio;
    if (inicio == null) return;

    final now    = DateTime.now();
    final datos  = _hitoDatos(inicio);

    // Busca el primer hito futuro (= hito "actual" pendiente)
    final currentIdx = datos.indexWhere((h) => !h.fecha.isBefore(now));

    if (currentIdx == -1) {
      // Todos completados
      final last = datos.last;
      hitoActualValor    = 'Mes ${last.meses}';
      hitoActualDetalle  = last.titulo;
      proximoHitoValor   = '—';
      proximoHitoDetalle = 'Proyecto completado';
    } else {
      final curr = datos[currentIdx];
      hitoActualValor   = 'Mes ${curr.meses}';
      hitoActualDetalle = curr.titulo;

      if (currentIdx + 1 < datos.length) {
        final next      = datos[currentIdx + 1];
        final diasRest  = next.fecha.difference(now).inDays.clamp(1, 9999);
        proximoHitoValor   = 'En $diasRest días';
        proximoHitoDetalle = next.titulo;
      } else {
        proximoHitoValor   = '—';
        proximoHitoDetalle = 'Último hito';
      }
    }

    final sembrados = (totalArboles * avance).round();
    final vivos     = (sembrados * 0.87).round();
    arbolesVivosValor   = '$vivos / $sembrados';
    arbolesVivosDetalle = 'Supervivencia 87%';
  }
}
