import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/mock_data.dart';

/// Precio base por árbol en COP (Bosque nativo, multiplicador ×1.0). Los
/// demás tipos se obtienen multiplicando por [TipoProyectoX.multiplicador].
const double basePricePerTreeCOP = 28000;

// `customPattern` fuerza el símbolo antes del número: intl no trae datos
// específicos de 'es_CO' y cae al patrón de 'es', que pone el símbolo
// después (p. ej. "28.000 $") — el separador de miles ('.') sí es correcto.
final _copFormat = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
  customPattern: '¤#,##0',
);

String formatCOP(double v) => _copFormat.format(v);

enum TipoProyecto { bosqueNativo, mixto, premium }

extension TipoProyectoX on TipoProyecto {
  String get label => switch (this) {
        TipoProyecto.bosqueNativo => 'Bosque nativo',
        TipoProyecto.mixto => 'Mixto',
        TipoProyecto.premium => 'Premium',
      };
  double get multiplicador => switch (this) {
        TipoProyecto.bosqueNativo => 1.0,
        TipoProyecto.mixto => 1.25,
        TipoProyecto.premium => 1.6,
      };
  String get precioLabel => formatCOP(basePricePerTreeCOP * multiplicador);
  String get multLabel => switch (this) {
        TipoProyecto.bosqueNativo => '×1.0',
        TipoProyecto.mixto => '×1.25',
        TipoProyecto.premium => '×1.6',
      };
}

enum ZonaEcologica { andina, caribe, amazonica }

extension ZonaEcologicaX on ZonaEcologica {
  String get label => switch (this) {
        ZonaEcologica.andina =>
          'Área de Vida Medellín Norte · Zona Andina',
        ZonaEcologica.caribe =>
          'Montes de María, Bolívar · Zona Caribe',
        ZonaEcologica.amazonica =>
          'Bajo Caquetá, Caquetá · Zona Amazónica',
      };
}

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
    EspecieCalc(
      nombre: 'Nogal cafetero',
      nombreCientifico: 'Cordia alliodora',
      tipoArbol: TipoArbol.broad,
    ),
    EspecieCalc(
      nombre: 'Cedro negro',
      nombreCientifico: 'Juglans neotropica',
      tipoArbol: TipoArbol.conical,
    ),
    EspecieCalc(
      nombre: 'Yarumo',
      nombreCientifico: 'Cecropia peltata',
      tipoArbol: TipoArbol.broad,
    ),
    EspecieCalc(
      nombre: 'Roble',
      nombreCientifico: 'Quercus humboldtii',
      tipoArbol: TipoArbol.conical,
    ),
  ],
  ZonaEcologica.caribe: [
    EspecieCalc(
      nombre: 'Trupillo',
      nombreCientifico: 'Prosopis juliflora',
      tipoArbol: TipoArbol.broad,
    ),
    EspecieCalc(
      nombre: 'Dividivi',
      nombreCientifico: 'Libidibia coriaria',
      tipoArbol: TipoArbol.broad,
    ),
    EspecieCalc(
      nombre: 'Caracolí',
      nombreCientifico: 'Anacardium excelsum',
      tipoArbol: TipoArbol.broad,
    ),
  ],
  ZonaEcologica.amazonica: [
    EspecieCalc(
      nombre: 'Abarco',
      nombreCientifico: 'Cariniana pyriformis',
      tipoArbol: TipoArbol.conical,
    ),
    EspecieCalc(
      nombre: 'Canangucho',
      nombreCientifico: 'Mauritia flexuosa',
      tipoArbol: TipoArbol.palm,
    ),
    EspecieCalc(
      nombre: 'Cedro rosado',
      nombreCientifico: 'Cedrela odorata',
      tipoArbol: TipoArbol.conical,
    ),
  ],
};

class CotizacionFormProvider extends ChangeNotifier {
  int trees = 1000;
  TipoProyecto tipo = TipoProyecto.bosqueNativo;
  ZonaEcologica territorio = ZonaEcologica.andina;
  int selectedSpeciesIndex = 0;
  bool maintenance = false;
  bool legalBannerOpen = true;
  bool quoteSent = false;

  List<EspecieCalc> get especiesActuales => _especiesPorZona[territorio]!;
  EspecieCalc get especieSeleccionada => especiesActuales[selectedSpeciesIndex];

  double get precioBase => basePricePerTreeCOP;
  double get precioPorArbol => precioBase * tipo.multiplicador;
  double get subtotal => trees * precioBase * tipo.multiplicador;
  double get maintenanceCost => maintenance ? subtotal * 0.15 : 0;
  double get total => subtotal + maintenanceCost;
  double get co2Anio => trees * 0.022;

  void setTrees(int v) { trees = v; quoteSent = false; notifyListeners(); }
  void setTipo(TipoProyecto v) { tipo = v; quoteSent = false; notifyListeners(); }
  void setTerritorio(ZonaEcologica v) {
    territorio = v;
    selectedSpeciesIndex = 0;
    quoteSent = false;
    notifyListeners();
  }
  void setSpeciesIndex(int i) { selectedSpeciesIndex = i; quoteSent = false; notifyListeners(); }
  void setMaintenance(bool v) { maintenance = v; quoteSent = false; notifyListeners(); }
  void closeLegalBanner() { legalBannerOpen = false; notifyListeners(); }
  void sendQuote() { quoteSent = true; notifyListeners(); }
}
