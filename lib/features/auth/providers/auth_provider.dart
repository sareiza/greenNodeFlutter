import 'package:flutter/foundation.dart';

/// Estado de sesión global de la app (simulado, sin backend real).
class AuthProvider extends ChangeNotifier {
  String? _userEmail;
  String? _token;

  bool get isLoggedIn => _token != null;
  String? get userEmail => _userEmail;

  void login({String? email}) {
    _userEmail = email;
    _token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
  }

  void logout() {
    _userEmail = null;
    _token = null;
    notifyListeners();
  }
}

/// Instancia única compartida entre el router (para el guard de rutas
/// protegidas) y el árbol de widgets (vía `ChangeNotifierProvider.value`
/// en main.dart) — ver app_router.dart → `redirect`/`refreshListenable`.
final authProvider = AuthProvider();
