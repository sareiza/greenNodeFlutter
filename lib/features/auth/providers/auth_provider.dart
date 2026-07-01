import 'package:flutter/foundation.dart';

import '../../../data/mock_auth.dart';

/// Estado de sesión global de la app (simulado, sin backend real).
class AuthProvider extends ChangeNotifier {
  String? _userEmail;
  String? _token;
  String? _rolActual;
  String? _nombreUsuario;

  bool get isLoggedIn => _token != null;
  String? get userEmail => _userEmail;
  String? get rolActual => _rolActual;
  String? get nombreUsuario => _nombreUsuario;

  /// Busca en [mockUsuarios] por email + password.
  /// Lanza [Exception] con "Credenciales inválidas" si no coincide.
  void login({required String email, required String password}) {
    final usuario = mockUsuarios.firstWhere(
      (u) => u['email'] == email.trim() && u['password'] == password,
      orElse: () => {},
    );
    if (usuario.isEmpty) throw Exception('Credenciales inválidas');
    _userEmail = usuario['email'];
    _rolActual = usuario['rol'];
    _nombreUsuario = usuario['nombre'];
    _token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
  }

  /// Login directo sin validar credenciales — usado después de registro
  /// donde el usuario acaba de crear su cuenta (siempre rol empresa).
  void loginDirecto({required String email, String rol = 'empresa', String nombre = ''}) {
    _userEmail = email;
    _rolActual = rol;
    _nombreUsuario = nombre.isEmpty ? email : nombre;
    _token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
  }

  void logout() {
    _userEmail = null;
    _token = null;
    _rolActual = null;
    _nombreUsuario = null;
    notifyListeners();
  }
}

/// Instancia única compartida entre el router (para el guard de rutas
/// protegidas) y el árbol de widgets (vía `ChangeNotifierProvider.value`
/// en main.dart) — ver app_router.dart → `redirect`/`refreshListenable`.
final authProvider = AuthProvider();
