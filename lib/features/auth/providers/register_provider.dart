import 'package:flutter/foundation.dart';

/// Estado del formulario "Registrar empresa" (3 pasos).
/// Fuente: design_handoff_greennode/README.md → sección 2.
class RegisterProvider extends ChangeNotifier {
  static const sectors = ['Tecnología', 'Manufactura', 'Finanzas', 'Retail', 'Energía', 'Otro'];
  static const employeeRanges = ['1–10', '11–50', '51–200', '201–500', '500+'];

  int _step = 1;
  String company = '';
  String sector = sectors.first;
  String empEmail = '';
  String employees = employeeRanges[2];
  String password = '';
  String confirmPassword = '';
  bool acceptTerms = false;
  bool registered = false;

  int get step => _step;
  double get progress => _step / 3;
  String get stepLabel => 'Paso $_step de 3';
  bool get canGoBack => _step > 1;
  bool get showContinue => _step < 3;
  bool get isLastStep => _step == 3;

  void setCompany(String v) {
    company = v;
    notifyListeners();
  }

  void setSector(String v) {
    sector = v;
    notifyListeners();
  }

  void setEmpEmail(String v) {
    empEmail = v;
    notifyListeners();
  }

  void setEmployees(String v) {
    employees = v;
    notifyListeners();
  }

  void setPassword(String v) {
    password = v;
    notifyListeners();
  }

  void setConfirmPassword(String v) {
    confirmPassword = v;
    notifyListeners();
  }

  void toggleTerms() {
    acceptTerms = !acceptTerms;
    notifyListeners();
  }

  void nextStep() {
    if (_step < 3) _step++;
    notifyListeners();
  }

  void prevStep() {
    if (_step > 1) _step--;
    notifyListeners();
  }

  void register() {
    registered = true;
    notifyListeners();
  }

  void resetForAnother() {
    registered = false;
    _step = 1;
    notifyListeners();
  }
}
