import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/greennode_logo.dart';
import '../providers/auth_provider.dart';

/// Pantalla intermedia mostrada al abrir la app: revisa si hay una sesión
/// activa en [authProvider] y redirige a `/proyecto` o `/login` según
/// corresponda — no se queda nunca renderizada de forma permanente.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (authProvider.isLoggedIn) {
        context.go(
          authProvider.rolActual == 'admin' ? '/admin/dashboard' : '/proyecto',
        );
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [
              AppColors.bgGradientStart,
              AppColors.bgGradientMid,
              AppColors.bgGradientEnd,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GreenNodeLogo(size: 30),
              SizedBox(height: 22),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
