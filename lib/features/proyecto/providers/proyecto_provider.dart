import 'package:flutter/foundation.dart';

import '../../../data/mock_data.dart';

class ProyectoProvider extends ChangeNotifier {
  // ── Datos del proyecto ───────────────────────────────────────────────────
  String nombre = 'Bosque Constructora Verde';
  String periodo = 'Período 2024–2026';
  String area = 'Área de Vida Medellín Norte';
  double avance = 0.45; // 0.0 → 1.0

  // ── Mini-tarjetas ────────────────────────────────────────────────────────
  String hitoActualValor = 'Mes 6';
  String hitoActualDetalle = 'Medición de crecimiento';

  String proximoHitoValor = 'En 15 días';
  String proximoHitoDetalle = 'Carga de evidencia';

  String arbolesVivosValor = '45 / 100';
  String arbolesVivosDetalle = 'Supervivencia 100%';

  // ── Especies y timeline ──────────────────────────────────────────────────
  List<EspecieSembrada> especies = List.of(mockEspeciesSembradas);
  List<HitoTimeline> hitos = List.of(mockHitosTimeline);

  // ── Estado de carga (listo para conectar a API) ──────────────────────────
  bool isLoading = false;
  String? error;

  // ── Setters (simulan respuesta de API o acción del usuario) ──────────────

  void setAvance(double valor) {
    avance = valor.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setNombre(String v) {
    nombre = v;
    notifyListeners();
  }

  void setHitoActual(String valor, String detalle) {
    hitoActualValor = valor;
    hitoActualDetalle = detalle;
    notifyListeners();
  }

  void setProximoHito(String valor, String detalle) {
    proximoHitoValor = valor;
    proximoHitoDetalle = detalle;
    notifyListeners();
  }

  void setArbolesVivos(String valor, String detalle) {
    arbolesVivosValor = valor;
    arbolesVivosDetalle = detalle;
    notifyListeners();
  }

  void setEspecies(List<EspecieSembrada> lista) {
    especies = lista;
    notifyListeners();
  }

  void setHitos(List<HitoTimeline> lista) {
    hitos = lista;
    notifyListeners();
  }

  /// Simula una carga asíncrona desde una API.
  /// Reemplaza el cuerpo de este método con tu llamada real (http, Firebase…).
  Future<void> cargar() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // TODO: reemplazar por await ApiService.getProyecto(id)
      await Future.delayed(const Duration(milliseconds: 600));
      // Los valores ya están inicializados desde el mock — no hace falta
      // asignarlos de nuevo hasta que exista un backend real.
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
