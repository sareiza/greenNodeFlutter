import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/cotizacion/screens/cotizacion_form_screen.dart';
import '../../features/cotizacion/screens/cotizacion_lista_screen.dart';
import '../../features/proyecto/screens/proyecto_overview_screen.dart';
import '../../features/proyecto/screens/areas_siembra_screen.dart';
import '../../features/proyecto/screens/certificado_screen.dart';
import '../../features/proyecto/widgets/evidencia_galeria.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../../main.dart';

/// Rutas accesibles sin sesión activa. Cualquier otra ruta requiere estar
/// autenticado en [authProvider]; si no lo está, `redirect` la manda a
/// `/login` — esto es lo que evita que el botón "atrás" del navegador
/// regrese a una pantalla protegida después de cerrar sesión.
const _publicPaths = {'/splash', '/login', '/register'};

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: authProvider,
  redirect: (context, state) {
    final loggedIn = authProvider.isLoggedIn;
    final loc = state.matchedLocation;
    if (!loggedIn && !_publicPaths.contains(loc)) return '/login';
    return null;
  },
  routes: [
    // Fuera del rail: pantallas previas a "entrar" a la app.
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    // Dentro del rail: el resto de la app, ya autenticado.
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.toString(), child: child),
      routes: [
        GoRoute(
          path: '/proyecto',
          builder: (context, state) => const ProyectoOverviewScreen(),
        ),
        GoRoute(
          path: '/cotizaciones',
          builder: (context, state) => const CotizacionListaScreen(),
        ),
        GoRoute(
          path: '/cotizar',
          builder: (context, state) => const CotizacionFormScreen(),
        ),
        GoRoute(
          path: '/evidencias',
          builder: (context, state) => const EvidenciaGaleriaScreen(),
        ),
        GoRoute(
          path: '/certificado',
          builder: (context, state) => const CertificadoScreen(),
        ),
        GoRoute(
          path: '/areas-siembra',
          builder: (context, state) => const AreasSiembraScreen(),
        ),
        GoRoute(
          path: '/asistente',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Asistente Aura',
            subtitle: 'Chat de ayuda — próximamente.',
            icon: Icons.smart_toy_outlined,
          ),
        ),
      ],
    ),
  ],
);
