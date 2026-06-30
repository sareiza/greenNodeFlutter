// Servicio simulado que imita el comportamiento de una API real,
// incluyendo latencia de red, mientras GreenNode no tiene backend propio.

import 'dart:math';

import 'mock_data.dart';

class MockService {
  final Random _random = Random();

  /// Espera entre 500ms y 800ms antes de devolver [value], simulando latencia.
  Future<T> _withLatency<T>(T value) async {
    final ms = 500 + _random.nextInt(301); // 500..800
    await Future.delayed(Duration(milliseconds: ms));
    return value;
  }

  Future<Empresa> getEmpresa() {
    return _withLatency(mockEmpresa);
  }

  Future<List<Cotizacion>> getCotizaciones() {
    return _withLatency(List<Cotizacion>.unmodifiable(mockCotizaciones));
  }

  Future<Cotizacion?> getCotizacionById(String id) async {
    Cotizacion? encontrada;
    for (final cotizacion in mockCotizaciones) {
      if (cotizacion.id == id) {
        encontrada = cotizacion;
        break;
      }
    }
    return _withLatency(encontrada);
  }

  Future<Proyecto> getProyecto() {
    return _withLatency(mockProyecto);
  }

  Future<List<Territorio>> getTerritorios() {
    return _withLatency(List<Territorio>.unmodifiable(mockTerritorios));
  }

  Future<List<Especie>> getEspeciesPorZona(String zona) async {
    final filtradas = mockEspecies
        .where((especie) => especie.zona.toLowerCase() == zona.toLowerCase())
        .toList();
    return _withLatency(filtradas);
  }

  Future<MarcoLegal> getMarcoLegal() {
    return _withLatency(mockMarcoLegal);
  }

  /// Simula el envío de una cotización a un servidor real, con un delay
  /// fijo de 2 segundos que representa el procesamiento del lado del servidor.
  Future<Map<String, dynamic>> enviarCotizacion(
    Map<String, dynamic> datos,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'id': 'cot-${1000 + _random.nextInt(9000)}',
      'mensaje': 'Cotización enviada correctamente.',
      'datos': datos,
    };
  }
}
