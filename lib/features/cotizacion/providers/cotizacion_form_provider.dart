import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/mock_data.dart'; // TipoArbol

/// Precio base por árbol en COP (Bosque nativo, multiplicador ×1.0).
const double basePricePerTreeCOP = 28000;

final _copFormat = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
  customPattern: '¤#,##0',
);

String formatCOP(double v) => _copFormat.format(v);

// ─── Territorio API ───────────────────────────────────────────────────────────

class TerritorioItem {
  final String id;
  final String nombre;

  const TerritorioItem({required this.id, required this.nombre});

  factory TerritorioItem.fromJson(Map<String, dynamic> j) => TerritorioItem(
        id:     j['id']?.toString() ?? '',
        nombre: j['name']?.toString() ?? j['nombre']?.toString() ?? '—',
      );

  // Fallback cuando el API falla o devuelve vacío
  static const fallback = [
    TerritorioItem(id: 'ter-001', nombre: 'Bosque San Martín · Zona Amazónica'),
    TerritorioItem(id: 'ter-002', nombre: 'Valle del Mantaro · Zona Andina'),
    TerritorioItem(id: 'ter-003', nombre: 'Desierto Verde Ica · Zona Costera'),
  ];

  @override
  bool operator ==(Object other) => other is TerritorioItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ─── Tipos de proyecto ────────────────────────────────────────────────────────

enum TipoProyecto { bosqueNativo, mixto, premium }

extension TipoProyectoX on TipoProyecto {
  String get label => switch (this) {
        TipoProyecto.bosqueNativo => 'Bosque nativo',
        TipoProyecto.mixto        => 'Mixto',
        TipoProyecto.premium      => 'Premium',
      };
  double get multiplicador => switch (this) {
        TipoProyecto.bosqueNativo => 1.0,
        TipoProyecto.mixto        => 1.25,
        TipoProyecto.premium      => 1.6,
      };
  String get precioLabel => formatCOP(basePricePerTreeCOP * multiplicador);
  String get multLabel => switch (this) {
        TipoProyecto.bosqueNativo => '×1.0',
        TipoProyecto.mixto        => '×1.25',
        TipoProyecto.premium      => '×1.6',
      };
}

// ─── Zona ecológica (solo para el selector de especies) ───────────────────────

enum ZonaEcologica { andina, caribe, amazonica }

extension ZonaEcologicaX on ZonaEcologica {
  String get label => switch (this) {
        ZonaEcologica.andina    => 'Zona Andina',
        ZonaEcologica.caribe    => 'Zona Caribe',
        ZonaEcologica.amazonica => 'Zona Amazónica',
      };
}

// ─── Especie ──────────────────────────────────────────────────────────────────

class EspecieCalc {
  final String nombre;
  final String nombreCientifico;
  final TipoArbol tipoArbol;

  const EspecieCalc({
    required this.nombre,
    required this.nombreCientifico,
    required this.tipoArbol,
  });
}

const _especiesPorZona = <ZonaEcologica, List<EspecieCalc>>{
  ZonaEcologica.andina: [
    EspecieCalc(nombre: 'Nogal cafetero', nombreCientifico: 'Cordia alliodora',    tipoArbol: TipoArbol.broad),
    EspecieCalc(nombre: 'Cedro negro',    nombreCientifico: 'Juglans neotropica',  tipoArbol: TipoArbol.conical),
    EspecieCalc(nombre: 'Yarumo',         nombreCientifico: 'Cecropia peltata',    tipoArbol: TipoArbol.broad),
    EspecieCalc(nombre: 'Roble',          nombreCientifico: 'Quercus humboldtii',  tipoArbol: TipoArbol.conical),
  ],
  ZonaEcologica.caribe: [
    EspecieCalc(nombre: 'Trupillo',  nombreCientifico: 'Prosopis juliflora',    tipoArbol: TipoArbol.broad),
    EspecieCalc(nombre: 'Dividivi',  nombreCientifico: 'Libidibia coriaria',    tipoArbol: TipoArbol.broad),
    EspecieCalc(nombre: 'Caracolí',  nombreCientifico: 'Anacardium excelsum',   tipoArbol: TipoArbol.broad),
  ],
  ZonaEcologica.amazonica: [
    EspecieCalc(nombre: 'Abarco',       nombreCientifico: 'Cariniana pyriformis', tipoArbol: TipoArbol.conical),
    EspecieCalc(nombre: 'Canangucho',   nombreCientifico: 'Mauritia flexuosa',    tipoArbol: TipoArbol.palm),
    EspecieCalc(nombre: 'Cedro rosado', nombreCientifico: 'Cedrela odorata',      tipoArbol: TipoArbol.conical),
  ],
};

// ─── Provider ─────────────────────────────────────────────────────────────────

class CotizacionFormProvider extends ChangeNotifier {
  int trees = 1000;
  TipoProyecto tipo = TipoProyecto.bosqueNativo;

  // Territorio real del API
  TerritorioItem? selectedTerritory;

  // Zona para el selector de especies (independiente del territorio API)
  ZonaEcologica zonaEspecies = ZonaEcologica.andina;
  int selectedSpeciesIndex = 0;

  bool maintenance    = false;
  bool legalBannerOpen = true;

  List<EspecieCalc> get especiesActuales => _especiesPorZona[zonaEspecies]!;
  EspecieCalc get especieSeleccionada {
    final list = especiesActuales;
    final idx  = selectedSpeciesIndex.clamp(0, list.length - 1);
    return list[idx];
  }

  double get precioBase      => basePricePerTreeCOP;
  double get precioPorArbol  => precioBase * tipo.multiplicador;
  double get subtotal        => trees * precioBase * tipo.multiplicador;
  double get maintenanceCost => maintenance ? subtotal * 0.15 : 0;
  double get total           => subtotal + maintenanceCost;
  double get co2Anio         => trees * 0.022;

  void setTrees(int v)                   { trees = v;                  notifyListeners(); }
  void setTipo(TipoProyecto v)           { tipo = v;                   notifyListeners(); }
  void setTerritorioApi(TerritorioItem t){ selectedTerritory = t;      notifyListeners(); }
  void setZonaEspecies(ZonaEcologica v)  {
    zonaEspecies = v;
    selectedSpeciesIndex = 0;
    notifyListeners();
  }
  void setSpeciesIndex(int i)            { selectedSpeciesIndex = i;   notifyListeners(); }
  void setMaintenance(bool v)            { maintenance = v;            notifyListeners(); }
  void closeLegalBanner()                { legalBannerOpen = false;    notifyListeners(); }
}
