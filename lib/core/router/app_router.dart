import 'package:go_router/go_router.dart';

import '../../features/admin_cotizaciones/screens/cotizacion_detalle_admin_screen.dart';
import '../../features/admin_cotizaciones/screens/cotizaciones_pendientes_screen.dart';
import '../../features/admin_dashboard/screens/dashboard_screen.dart';
import '../../features/admin_empresas/screens/empresas_screen.dart';
import '../../features/admin_proyecto/screens/proyectos_admin_screen.dart';
import '../../features/admin_proyecto/screens/proyecto_detalle_admin_screen.dart';
import '../../features/landing/screens/landing_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/cotizacion/screens/cotizacion_detalle_screen.dart';
import '../../features/cotizacion/screens/cotizacion_form_screen.dart';
import '../../features/cotizacion/screens/cotizacion_lista_screen.dart';
import '../../features/chatbot/screens/chat_screen.dart';
import '../../features/proyecto/screens/proyecto_overview_screen.dart';
import '../../features/proyecto/screens/areas_siembra_screen.dart';
import '../../features/proyecto/screens/certificado_screen.dart';
import '../../features/proyecto/widgets/evidencia_galeria.dart';
import '../../main.dart';

/// Rutas accesibles sin sesión activa. Cualquier otra ruta requiere estar
/// autenticado en [authProvider]; si no lo está, `redirect` la manda a
/// `/login` — esto es lo que evita que el botón "atrás" del navegador
/// regrese a una pantalla protegida después de cerrar sesión.
const _publicPaths = {'/', '/splash', '/login', '/register'};

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: authProvider,
  redirect: (context, state) {
    final loggedIn = authProvider.isLoggedIn;
    final rol = authProvider.rolActual;
    final loc = state.matchedLocation;

    // Sin sesión → login
    if (!loggedIn && !_publicPaths.contains(loc)) return '/login';

    // Empresa intentando acceder a rutas de admin
    if (loggedIn && rol == 'empresa' && loc.startsWith('/admin')) {
      return '/proyecto';
    }

    // Admin intentando acceder a rutas de empresa
    if (loggedIn && rol == 'admin' && !loc.startsWith('/admin') && !_publicPaths.contains(loc)) {
      return '/admin/dashboard';
    }

    return null;
  },
  routes: [
    // Landing pública (antes de registrarse).
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
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
          path: '/cotizaciones/:id',
          builder: (context, state) =>
              CotizacionDetalleScreen(id: state.pathParameters['id']!),
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
          builder: (context, state) => const ChatScreen(),
        ),
      ],
    ),
    // Panel admin: shell propio con rail lateral.
    ShellRoute(
      builder: (context, state, child) =>
          AdminShell(location: state.uri.toString(), child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/admin/cotizaciones',
          builder: (context, state) => const CotizacionesPendientesScreen(),
        ),
        GoRoute(
          path: '/admin/cotizaciones/:id',
          builder: (context, state) =>
              CotizacionDetalleAdminScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/empresas',
          builder: (context, state) => const EmpresasScreen(),
        ),
        GoRoute(
          path: '/admin/proyectos',
          builder: (context, state) => const ProyectosAdminScreen(),
        ),
        GoRoute(
          path: '/admin/proyecto/:id',
          builder: (context, state) =>
              ProyectoDetalleAdminScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);
