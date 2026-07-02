import 'package:flutter/foundation.dart';

import '../../../data/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _userEmail;
  String? _token;
  String? _rolActual;
  String? _nombreUsuario;
  String? _sector;

  bool get isLoggedIn => _token != null;
  String? get userEmail => _userEmail;
  String? get rolActual => _rolActual;
  String? get nombreUsuario => _nombreUsuario;
  String? get sector => _sector;

  Future<void> login({required String email, required String password}) async {
    final data = await ApiService().login(email.trim(), password);
    _token = data['token'] as String?;
    _userEmail = data['email'] as String? ?? email.trim();
    final role = (data['role'] as String? ?? '').toLowerCase();
    _rolActual = role == 'admin' ? 'admin' : 'empresa';
    _nombreUsuario = _rolActual == 'admin' ? 'Administrador GreenNode' : _userEmail;
    _sector = data['sector'] as String? ?? data['company']?['sector'] as String?;
    notifyListeners();
  }

  /// Login directo sin validar credenciales — usado después de registro.
  void loginDirecto({required String email, String rol = 'empresa', String nombre = '', String sector = ''}) {
    _userEmail = email;
    _rolActual = rol;
    _nombreUsuario = nombre.isEmpty ? email : nombre;
    _sector = sector.isEmpty ? null : sector;
    _token = 'local-token-${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
  }

  void logout() {
    ApiService.clearToken();
    _userEmail = null;
    _token = null;
    _rolActual = null;
    _nombreUsuario = null;
    notifyListeners();
  }
}

/// Instancia única compartida entre el router y el árbol de widgets.
final authProvider = AuthProvider();
