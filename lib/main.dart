import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/widgets/greennode_logo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp.router(
        title: 'GreenNode',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}

// ─── App shell: rail lateral + panel de contenido ────────────────────────────
//
// Fuente: design_handoff_greennode/README.md → "Screens / Views".
// La app es una sola pantalla con rail lateral (ancho 264) sobre un degradado
// #15462F → #0E2C1E, y un panel de contenido que cambia según la opción
// activa (provista por el ShellRoute de app_router.dart).

class _RailItem {
  final String label;
  final IconData icon;
  final String path;
  const _RailItem(this.label, this.icon, this.path);
}

class _RailGroup {
  final String title;
  final List<_RailItem> items;
  const _RailGroup(this.title, this.items);
}

const _railGroups = [
  _RailGroup('Mi programa', [
    _RailItem('Mi proyecto', Icons.eco_outlined, '/proyecto'),
    _RailItem('Mis cotizaciones', Icons.receipt_long_outlined, '/cotizaciones'),
    _RailItem('Evidencias', Icons.photo_library_outlined, '/evidencias'),
    _RailItem('Certificado', Icons.verified_outlined, '/certificado'),
    _RailItem('Áreas de siembra', Icons.map_outlined, '/areas-siembra'),
  ]),
  _RailGroup('Herramientas', [
    _RailItem('Cotización', Icons.calculate_outlined, '/cotizar'),
    _RailItem('Asistente', Icons.smart_toy_outlined, '/asistente'),
  ]),
];

const _adminRailGroups = [
  _RailGroup('Panel de administración', [
    _RailItem('Dashboard', Icons.dashboard_outlined, '/admin/dashboard'),
    _RailItem('Cotizaciones', Icons.description_outlined, '/admin/cotizaciones'),
    _RailItem('Empresas', Icons.business_outlined, '/admin/empresas'),
    _RailItem('Proyectos', Icons.forest_outlined, '/admin/proyectos'),
  ]),
];

/// Ancho mínimo a partir del cual se muestra el rail lateral fijo. Por
/// debajo de este ancho (móvil) el rail se reemplaza por un [Drawer].
const _railBreakpoint = 800.0;

/// Shell persistente usado por el [ShellRoute] de app_router.dart.
///
/// >= 800px (web/tablet/desktop): rail lateral fijo de 264px + [child] como
/// panel de contenido, igual que antes.
/// < 800px (móvil): el rail se reemplaza por un [Drawer] deslizable con el
/// mismo contenido/gradiente, abierto desde el botón de hamburguesa del
/// [AppBar] superior — el rail fijo se ve roto en pantallas angostas porque
/// el texto de cada ítem se parte en vertical.
class AppShell extends StatelessWidget {
  final String location;
  final Widget child;

  const AppShell({super.key, required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _railBreakpoint) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AppRail(activePath: location),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.forest,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const GreenNodeLogo(
              size: 22,
              leafColor: AppColors.mint,
              textColor: Colors.white,
            ),
          ),
          drawer: Drawer(
            width: 280,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.forest, AppColors.forestDeep],
                ),
              ),
              child: _RailContent(activePath: location, insideDrawer: true),
            ),
          ),
          body: child,
        );
      },
    );
  }
}

class _AppRail extends StatelessWidget {
  final String activePath;
  const _AppRail({required this.activePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: _RailContent(activePath: activePath, insideDrawer: false),
    );
  }
}

/// Contenido compartido entre el rail fijo (desktop) y el [Drawer] (móvil):
/// logo, grupos de menú y tarjeta de stat. Cuando [insideDrawer] es true,
/// cada ítem cierra el drawer al navegar.
class _RailContent extends StatelessWidget {
  final String activePath;
  final bool insideDrawer;
  const _RailContent({required this.activePath, required this.insideDrawer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GreenNodeLogo(
                size: 24,
                leafColor: AppColors.mint,
                textColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final group in _railGroups) ...[
                    _RailGroupLabel(group.title),
                    const SizedBox(height: 6),
                    for (final item in group.items)
                      _RailMenuItem(
                        item: item,
                        active: item.path == activePath,
                        onTap: () {
                          context.go(item.path);
                          if (insideDrawer) Navigator.of(context).pop();
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _RailStatCard(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
            child: Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 16),
            child: _LogoutButton(insideDrawer: insideDrawer),
          ),
        ],
      ),
    );
  }
}

class _RailGroupLabel extends StatelessWidget {
  final String text;
  const _RailGroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.hankenGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.88,
          color: Colors.white.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}

class _RailMenuItem extends StatefulWidget {
  final _RailItem item;
  final bool active;
  final VoidCallback onTap;
  const _RailMenuItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  State<_RailMenuItem> createState() => _RailMenuItemState();
}

class _RailMenuItemState extends State<_RailMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final bg = active
        ? Colors.white.withValues(alpha: 0.15)
        : _hovered
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent;
    final fg = active ? Colors.white : Colors.white.withValues(alpha: 0.62);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(widget.item.icon, size: 18, color: fg),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ítem "Cerrar sesión", con el mismo estilo visual/hover que
/// [_RailMenuItem] pero sin estado "activo" (no es un destino del rail).
class _LogoutButton extends StatefulWidget {
  final bool insideDrawer;
  const _LogoutButton({required this.insideDrawer});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _hovered = false;

  void _handleLogout(BuildContext context) {
    // Cierra el drawer (si aplica) antes de salir del shell: tras el
    // logout, '/login' está fuera del ShellRoute y desmonta este widget.
    if (widget.insideDrawer) Navigator.of(context).pop();
    context.read<AuthProvider>().logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final fg = Colors.white.withValues(alpha: 0.62);
    final bg = _hovered ? Colors.white.withValues(alpha: 0.08) : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _handleLogout(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 18, color: fg),
              const SizedBox(width: 11),
              Text(
                'Cerrar sesión',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailStatCard extends StatelessWidget {
  const _RailStatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1.2M',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'árboles plantados por 340 empresas',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Admin shell: rail lateral + panel de contenido (panel admin) ─────────────

class AdminShell extends StatelessWidget {
  final String location;
  final Widget child;
  const AdminShell({super.key, required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _railBreakpoint) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AdminRail(activePath: location),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.forest,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const GreenNodeLogo(
              size: 22,
              leafColor: AppColors.mint,
              textColor: Colors.white,
            ),
          ),
          drawer: Drawer(
            width: 280,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.forest, AppColors.forestDeep],
                ),
              ),
              child: _AdminRailContent(activePath: location, insideDrawer: true),
            ),
          ),
          body: child,
        );
      },
    );
  }
}

class _AdminRail extends StatelessWidget {
  final String activePath;
  const _AdminRail({required this.activePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: _AdminRailContent(activePath: activePath, insideDrawer: false),
    );
  }
}

class _AdminRailContent extends StatelessWidget {
  final String activePath;
  final bool insideDrawer;
  const _AdminRailContent({required this.activePath, required this.insideDrawer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GreenNodeLogo(
                size: 24,
                leafColor: AppColors.mint,
                textColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Panel de administración',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final group in _adminRailGroups) ...[
                    _RailGroupLabel(group.title),
                    const SizedBox(height: 6),
                    for (final item in group.items)
                      _RailMenuItem(
                        item: item,
                        active: activePath == item.path ||
                            (item.path == '/admin/proyectos' &&
                                activePath.startsWith('/admin/proyecto')) ||
                            (item.path != '/admin/dashboard' &&
                                item.path != '/admin/proyectos' &&
                                activePath.startsWith(item.path)),
                        onTap: () {
                          context.go(item.path);
                          if (insideDrawer) Navigator.of(context).pop();
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
            child: Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 16),
            child: _LogoutButton(insideDrawer: insideDrawer),
          ),
        ],
      ),
    );
  }
}
