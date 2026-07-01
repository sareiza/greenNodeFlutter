import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/greennode_logo.dart';

// ─── Datos de secciones ───────────────────────────────────────────────────────

const _stats = [
  ('1.2M', 'árboles plantados'),
  ('340', 'empresas activas'),
  ('87%', 'tasa de supervivencia'),
  ('24', 'departamentos cubiertos'),
];

const _pasos = [
  (
    num: '01',
    titulo: 'Cotiza',
    desc:
        'Completa el formulario con tus datos. La IA genera tu plan de reforestación en segundos.',
    icon: Icons.calculate_outlined,
  ),
  (
    num: '02',
    titulo: 'Aprobamos',
    desc:
        'Nuestro equipo revisa y personaliza tu proyecto según tu territorio y especie ideal.',
    icon: Icons.verified_outlined,
  ),
  (
    num: '03',
    titulo: 'Monitorea',
    desc:
        'Sigue el avance en tiempo real desde tu panel: fotos, árboles sembrados y certificado.',
    icon: Icons.monitor_outlined,
  ),
];

const _especies = [
  (
    nombre: 'Nogal cafetero',
    cientifico: 'Cordia alliodora',
    zona: 'Zona Andina',
    icon: Icons.park_outlined,
  ),
  (
    nombre: 'Cedro negro',
    cientifico: 'Juglans neotropica',
    zona: 'Zona Andina',
    icon: Icons.eco_outlined,
  ),
  (
    nombre: 'Caracolí',
    cientifico: 'Anacardium excelsum',
    zona: 'Zona Caribe',
    icon: Icons.nature_outlined,
  ),
  (
    nombre: 'Abarco',
    cientifico: 'Cariniana pyriformis',
    zona: 'Zona Amazónica',
    icon: Icons.forest_outlined,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey _seccion3Key = GlobalKey();

  void _irAComoFunciona() {
    final ctx = _seccion3Key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(onVerComoFunciona: _irAComoFunciona),
            const _StatsSection(),
            _ComoFuncionaSection(sectionKey: _seccion3Key),
            const _EspeciesSection(),
            const _MarcoLegalSection(),
            const _CtaSection(),
            const _LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Contenedor centrado (max-width) ─────────────────────────────────────────

class _Centered extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const _Centered({
    required this.child,
    this.maxWidth = 1100,
    this.padding = const EdgeInsets.symmetric(horizontal: 48),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// ─── SECCIÓN 1: Hero ──────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final VoidCallback onVerComoFunciona;
  const _HeroSection({required this.onVerComoFunciona});

  @override
  Widget build(BuildContext context) {
    final titleSize = MediaQuery.of(context).size.width > 640 ? 54.0 : 36.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: Column(
        children: [
          // Nav
          _Centered(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 22),
            child: Row(
              children: [
                const GreenNodeLogo(
                  size: 22,
                  leafColor: AppColors.mint,
                  textColor: Colors.white,
                ),
                const Spacer(),
                _NavLink(label: 'Iniciar sesión', onTap: () => context.push('/login')),
              ],
            ),
          ),

          // Hero content
          _Centered(
            maxWidth: 800,
            padding: const EdgeInsets.fromLTRB(48, 44, 48, 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo grande
                const GreenNodeLogo(
                  size: 48,
                  leafColor: AppColors.mint,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 38),

                // Título
                Text(
                  'Tu empresa.\nSu bosque. El futuro.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 22),

                // Subtítulo
                Text(
                  'Cumple la Ley 2173 de 2021 y compensa tu huella ambiental con proyectos de reforestación certificados en Colombia.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    height: 1.65,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 40),

                // Botones
                Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    _HeroPrimaryBtn(
                      label: 'Solicitar cotización',
                      onTap: () => context.push('/register'),
                    ),
                    _HeroOutlineBtn(
                      label: 'Ver cómo funciona',
                      onTap: onVerComoFunciona,
                    ),
                  ],
                ),
                const SizedBox(height: 44),

                // Badge legal
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_outlined,
                          size: 15, color: AppColors.mint),
                      const SizedBox(width: 8),
                      Text(
                        'Ley 2173 · Res. 1491 de 2025 · ICA Certificado',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPrimaryBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _HeroPrimaryBtn({required this.label, required this.onTap});

  @override
  State<_HeroPrimaryBtn> createState() => _HeroPrimaryBtnState();
}

class _HeroPrimaryBtnState extends State<_HeroPrimaryBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.primaryHover : AppColors.primary,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hovered ? 0.45 : 0.3),
                blurRadius: _hovered ? 28 : 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroOutlineBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _HeroOutlineBtn({required this.label, required this.onTap});

  @override
  State<_HeroOutlineBtn> createState() => _HeroOutlineBtnState();
}

class _HeroOutlineBtnState extends State<_HeroOutlineBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.48),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SECCIÓN 2: Estadísticas ──────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: _Centered(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 560;
            if (wide) {
              return Row(
                children: [
                  for (int i = 0; i < _stats.length; i++) ...[
                    Expanded(child: _StatItem(_stats[i].$1, _stats[i].$2)),
                    if (i < _stats.length - 1)
                      Container(width: 1, height: 60, color: AppColors.line),
                  ],
                ],
              );
            }
            return Wrap(
              runSpacing: 36,
              children: [
                for (final s in _stats)
                  SizedBox(
                    width: constraints.maxWidth / 2,
                    child: _StatItem(s.$1, s.$2),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 46,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ─── SECCIÓN 3: Cómo funciona ─────────────────────────────────────────────────

class _ComoFuncionaSection extends StatelessWidget {
  final GlobalKey sectionKey;
  const _ComoFuncionaSection({required this.sectionKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      color: AppColors.surfaceMint,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _Centered(
        child: Column(
          children: [
            Text(
              'Tres pasos para tu bosque corporativo',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 52),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 680;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < _pasos.length; i++) ...[
                        Expanded(child: _PasoCard(_pasos[i])),
                        if (i < _pasos.length - 1) const SizedBox(width: 20),
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    for (int i = 0; i < _pasos.length; i++) ...[
                      _PasoCard(_pasos[i]),
                      if (i < _pasos.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PasoCard extends StatelessWidget {
  final ({String num, String titulo, String desc, IconData icon}) paso;
  const _PasoCard(this.paso);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0E102A1C), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(paso.icon, size: 22, color: AppColors.primary),
              ),
              const Spacer(),
              Text(
                paso.num,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.line,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            paso.titulo,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            paso.desc,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.65,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECCIÓN 4: Especies ──────────────────────────────────────────────────────

class _EspeciesSection extends StatelessWidget {
  const _EspeciesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _Centered(
        child: Column(
          children: [
            Text(
              'Especies nativas certificadas ICA',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Seleccionadas por zona biogeográfica y adaptadas a los ecosistemas de Colombia.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.55,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 860
                    ? 4
                    : constraints.maxWidth > 560
                        ? 2
                        : 1;
                final gap = 20.0;
                final cardW = (constraints.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final e in _especies)
                      SizedBox(width: cardW, child: _EspecieCard(e)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EspecieCard extends StatelessWidget {
  final ({String nombre, String cientifico, String zona, IconData icon}) especie;
  const _EspecieCard(this.especie);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(especie.icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            especie.nombre,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            especie.cientifico,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              especie.zona,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECCIÓN 5: Marco legal ───────────────────────────────────────────────────

class _MarcoLegalSection extends StatelessWidget {
  const _MarcoLegalSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.forest,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _Centered(
        maxWidth: 760,
        child: Column(
          children: [
            // Badge legal
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.mint.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.gavel_rounded,
                      size: 14, color: AppColors.mint),
                  const SizedBox(width: 8),
                  Text(
                    'Ley 2173 de 2021 · Resolución 1491 de 2025',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: AppColors.mint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Cumplimiento garantizado',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),

            Text(
              'La Ley 2173 de 2021 obliga a las empresas colombianas a sembrar mínimo 2 árboles nativos por empleado registrado ante el SENA. Con GreenNode, cumples este requisito con proyectos certificados ICA, seguimiento durante 2 años y emisión del Certificado Siembra Vida Buen Ciudadano por la autoridad ambiental competente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.7,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nuestros proyectos están respaldados por la Resolución 1491 de 2025 del Ministerio de Ambiente, que establece los estándares de calidad para los programas de compensación ambiental en Colombia.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.7,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),

            const SizedBox(height: 40),

            // Puntos de diferenciación
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 600;
                final items = [
                  (Icons.check_circle_outline_rounded, 'Mínimo 2 árboles por empleado'),
                  (Icons.check_circle_outline_rounded, 'Seguimiento por 2 años'),
                  (Icons.check_circle_outline_rounded, 'Certificado Siembra Vida'),
                  (Icons.check_circle_outline_rounded, 'Especies certificadas ICA'),
                ];
                if (wide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        _LegalBullet(items[i].$1, items[i].$2),
                        if (i < items.length - 1) const SizedBox(width: 32),
                      ],
                    ],
                  );
                }
                return Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final item in items) _LegalBullet(item.$1, item.$2),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _LegalBullet(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.mint),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}

// ─── SECCIÓN 6: CTA final ─────────────────────────────────────────────────────

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.forest],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _Centered(
        maxWidth: 680,
        child: Column(
          children: [
            Text(
              '¿Listo para plantar tu bosque corporativo?',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.18,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Únete a 340 empresas que ya compensan su huella ambiental con GreenNode.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.55,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 44),
            _CtaBtn(onTap: () => context.push('/register')),
          ],
        ),
      ),
    );
  }
}

class _CtaBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _CtaBtn({required this.onTap});

  @override
  State<_CtaBtn> createState() => _CtaBtnState();
}

class _CtaBtnState extends State<_CtaBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF2FAF5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.18 : 0.12),
                blurRadius: _hovered ? 28 : 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comenzar ahora',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _LandingFooter extends StatelessWidget {
  const _LandingFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: _Centered(
        child: Column(
          children: [
            const GreenNodeLogo(
              size: 20,
              leafColor: AppColors.mint,
              textColor: Colors.white,
            ),
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 36,
              runSpacing: 12,
              children: const [
                _FooterLink('Política de privacidad'),
                _FooterLink('Términos de uso'),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              '© 2026 GreenNode · Plataforma de reforestación corporativa basada en Ley 2173 de 2021',
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  const _FooterLink(this.label);

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _hovered
              ? Colors.white
              : Colors.white.withValues(alpha: 0.48),
        ),
        child: Text(widget.label),
      ),
    );
  }
}
