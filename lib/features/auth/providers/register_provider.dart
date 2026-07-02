import 'package:flutter/foundation.dart';

class RegisterProvider extends ChangeNotifier {
  // Valores que acepta el backend en el campo "sector"
  static const sectors = ['mining', 'energy', 'construction', 'food'];

  static const sectorLabels = {
    'mining':       'Minería',
    'energy':       'Energía',
    'construction': 'Construcción',
    'food':         'Alimentos',
  };

  static const employeeRanges = ['1–10', '11–50', '51–200', '201–500', '500+'];

  static const _employeeCountMap = {
    '1–10':    5,
    '11–50':   25,
    '51–200':  100,
    '201–500': 300,
    '500+':    500,
  };

  int _step = 1;
  String company     = '';
  String sector      = sectors.first;
  String empEmail    = '';
  String phone       = '';
  String employees   = employeeRanges[2];
  String password    = '';
  String confirmPassword = '';
  bool acceptTerms   = false;

  int get step => _step;
  double get progress => _step / 3;
  String get stepLabel => 'Paso $_step de 3';
  bool get canGoBack => _step > 1;
  bool get showContinue => _step < 3;

  // employeeCount numérico para el API
  int get employeeCountInt => _employeeCountMap[employees] ?? 100;

  void setCompany(String v)          { company = v;          notifyListeners(); }
  void setPhone(String v)            { phone = v;            notifyListeners(); }
  void setSector(String v)           { sector = v;           notifyListeners(); }
  void setEmpEmail(String v)         { empEmail = v;         notifyListeners(); }
  void setEmployees(String v)        { employees = v;        notifyListeners(); }
  void setPassword(String v)         { password = v;         notifyListeners(); }
  void setConfirmPassword(String v)  { confirmPassword = v;  notifyListeners(); }

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

  void reset() {
    _step = 1;
    company = '';
    phone = '';
    sector = sectors.first;
    empEmail = '';
    employees = employeeRanges[2];
    password = '';
    confirmPassword = '';
    acceptTerms = false;
    notifyListeners();
  }
}
