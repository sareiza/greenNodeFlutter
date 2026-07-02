import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api_service.dart';
import '../../../data/mock_data.dart'; // TipoArbol
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/loading_ia.dart';
import '../providers/cotizacion_form_provider.dart';

// ─── Helpers de formato ───────────────────────────────────────────────────────

String _fmtMoney(double v) => formatCOP(v);

String _fmtInt(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CotizacionFormScreen extends StatelessWidget {
  const CotizacionFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CotizacionFormProvider(),
      child: const _CotizacionFormView(),
    );
  }
}

// ─── Vista principal (StatefulWidget para cargar territorios) ─────────────────

class _CotizacionFormView extends StatefulWidget {
  const _CotizacionFormView();

  @override
  State<_CotizacionFormView> createState() => _CotizacionFormViewState();
}

class _CotizacionFormViewState extends State<_CotizacionFormView> {
  bool _loadingTerr = true;
  List<TerritorioItem> _territorios = [];

  @override
  void initState() {
    super.initState();
    _loadTerritorios();
  }

  Future<void> _loadTerritorios() async {
    try {
      final raw = await apiService.getTerritorios();
      if (!mounted) return;
      final list = raw
          .map((e) => TerritorioItem.fromJson(e as Map<String, dynamic>))
          .where((t) => t.id.isNotEmpty)
          .toList();
      final result = list.isNotEmpty ? list : TerritorioItem.fallback;
      if (!mounted) return;
      setState(() { _territorios = result; _loadingTerr = false; });
      context.read<CotizacionFormProvider>().setTerritorioApi(result.first);
    } catch (_) {
      if (!mounted) return;
      setState(() { _territorios = TerritorioItem.fallback; _loadingTerr = false; });
      context.read<CotizacionFormProvider>().setTerritorioApi(TerritorioItem.fallback.first);
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> _submitQuote() async {
    final provider   = context.read<CotizacionFormProvider>();
    final territory  = provider.selectedTerritory;
    if (territory == null) return;

    // Muestra animación IA
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingIADialog(),
    );

    try {
      await apiService.crearCotizacion({
        'territoryId':   territory.id,
        'numberOfTrees': provider.trees,
        'sector':        authProvider.sector ?? 'energy',
      });

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Cierra dialog IA

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Cotización enviada! La IA está generando tu propuesta.',
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 4),
        ),
      );

      context.go('/cotizaciones');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Cierra dialog IA

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: AppColors.rechazadoDot,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bannerOpen = context.select<CotizacionFormProvider, bool>(
      (p) => p.legalBannerOpen,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientMid, AppColors.bgGradientEnd],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = constraints.maxWidth < _bodyRowBreakpoint ? 16.0 : 40.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PageHeader(),
                  const SizedBox(height: 20),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: bannerOpen
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: _LegalBanner(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  _BodyRow(
                    territorios: _territorios,
                    loadingTerr: _loadingTerr,
                    onSubmit: _submitQuote,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Cabecera ─────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cotización',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26, fontWeight: FontWeight.w700,
            height: 1.1, letterSpacing: -0.52, color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Estima la inversión de tu bosque corporativo.',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ─── Banner legal ─────────────────────────────────────────────────────────────

class _LegalBanner extends StatelessWidget {
  const _LegalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Container(width: 3, height: 48, color: AppColors.primary),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textMuted,
                  ),
                  children: const [
                    TextSpan(text: 'Ley 2173',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                    TextSpan(text: ' · Mínimo 2 árboles por empleado · Res. 1491 de 2025'),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.read<CotizacionFormProvider>().closeLegalBanner(),
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMint, borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Layout de dos columnas ───────────────────────────────────────────────────

const _bodyRowBreakpoint = 700.0;

class _BodyRow extends StatelessWidget {
  final List<TerritorioItem> territorios;
  final bool loadingTerr;
  final VoidCallback onSubmit;

  const _BodyRow({
    required this.territorios,
    required this.loadingTerr,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final formCol = _FormColumn(territorios: territorios, loadingTerr: loadingTerr);
        final summaryCard = _SummaryCard(onSubmit: onSubmit);
        if (constraints.maxWidth < _bodyRowBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [formCol, const SizedBox(height: 24), summaryCard],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: formCol),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: summaryCard),
          ],
        );
      },
    );
  }
}

// ─── Columna de formulario ────────────────────────────────────────────────────

class _FormColumn extends StatelessWidget {
  final List<TerritorioItem> territorios;
  final bool loadingTerr;

  const _FormColumn({required this.territorios, required this.loadingTerr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormCard(child: _TreesSlider()),
        const SizedBox(height: 14),
        const _FormCard(child: _TypeChips()),
        const SizedBox(height: 14),
        _FormCard(child: _TerritorySection(territorios: territorios, loadingTerr: loadingTerr)),
        const SizedBox(height: 14),
        const _FormCard(child: _MaintenanceSwitch()),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x08102A1C), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: child,
    );
  }
}

// ─── Slider de árboles ────────────────────────────────────────────────────────

class _TreesSlider extends StatelessWidget {
  const _TreesSlider();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: _SectionLabel('Nº de árboles')),
            Text(
              _fmtInt(p.trees),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            thumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.line,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: p.trees.toDouble(),
            min: 100, max: 10000, divisions: 198,
            onChanged: (v) => p.setTrees(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100',    style: GoogleFonts.hankenGrotesk(fontSize: 12, color: AppColors.textSubtle)),
              Text('10,000', style: GoogleFonts.hankenGrotesk(fontSize: 12, color: AppColors.textSubtle)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Chips de tipo de proyecto ────────────────────────────────────────────────

class _TypeChips extends StatelessWidget {
  const _TypeChips();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Tipo de proyecto'),
        const SizedBox(height: 12),
        Row(
          children: TipoProyecto.values.map((tipo) {
            final isLast = tipo == TipoProyecto.premium;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _TypeChip(
                  tipo: tipo,
                  selected: p.tipo == tipo,
                  onTap: () => p.setTipo(tipo),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final TipoProyecto tipo;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.tipo, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FAF5) : AppColors.surfaceTint,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.inputBorder,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tipo.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${tipo.multLabel} · ${tipo.precioLabel}',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: selected ? AppColors.primary.withValues(alpha: 0.75) : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Territorio + especie nativa ─────────────────────────────────────────────

class _TerritorySection extends StatelessWidget {
  final List<TerritorioItem> territorios;
  final bool loadingTerr;

  const _TerritorySection({required this.territorios, required this.loadingTerr});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Territorio (API) ────────────────────────────────────────────────
        const _SectionLabel('Territorio'),
        const SizedBox(height: 10),
        if (loadingTerr)
          const SizedBox(
            height: 46,
            child: Center(
              child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              ),
            ),
          )
        else if (territorios.isEmpty)
          Text(
            'No hay territorios disponibles.',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
          )
        else
          _ApiTerritoryDropdown(
            value: p.selectedTerritory ?? territorios.first,
            territorios: territorios,
            onChanged: (t) { if (t != null) p.setTerritorioApi(t); },
          ),

        const SizedBox(height: 22),

        // ── Especie nativa ───────────────────────────────────────────────────
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10, runSpacing: 6,
          children: [
            const _SectionLabel('Especie nativa'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.aprobadoBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Solo especies nativas certificadas ICA · Ley 2173',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.aprobadoText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Chips de zona para las especies
        _ZonaChips(
          selected: p.zonaEspecies,
          onChanged: p.setZonaEspecies,
        ),
        const SizedBox(height: 12),
        _SpeciesGrid(
          especies: p.especiesActuales,
          selectedIndex: p.selectedSpeciesIndex,
          onSelect: p.setSpeciesIndex,
        ),
      ],
    );
  }
}

// ─── Dropdown de territorios del API ─────────────────────────────────────────

class _ApiTerritoryDropdown extends StatelessWidget {
  final TerritorioItem value;
  final List<TerritorioItem> territorios;
  final ValueChanged<TerritorioItem?> onChanged;

  const _ApiTerritoryDropdown({
    required this.value,
    required this.territorios,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = territorios.contains(value) ? value : territorios.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        border: Border.all(color: AppColors.inputBorder, width: 1.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: DropdownButton<TerritorioItem>(
        value: selected,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
        style: GoogleFonts.hankenGrotesk(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink,
        ),
        items: territorios.map((t) => DropdownMenuItem(
          value: t,
          child: Text(t.nombre, overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Chips de zona ecológica ──────────────────────────────────────────────────

class _ZonaChips extends StatelessWidget {
  final ZonaEcologica selected;
  final ValueChanged<ZonaEcologica> onChanged;
  const _ZonaChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: ZonaEcologica.values.map((z) {
        final sel = selected == z;
        return GestureDetector(
          onTap: () => onChanged(z),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: sel ? AppColors.primary : AppColors.line, width: 1.5),
            ),
            child: Text(
              z.label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Grid de especies ─────────────────────────────────────────────────────────

class _SpeciesGrid extends StatelessWidget {
  final List<EspecieCalc> especies;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _SpeciesGrid({required this.especies, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final colW = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap, runSpacing: gap,
          children: [
            for (var i = 0; i < especies.length; i++)
              SizedBox(
                width: colW,
                child: _SpeciesCard(
                  especie: especies[i],
                  selected: selectedIndex == i,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final EspecieCalc especie;
  final bool selected;
  final VoidCallback onTap;
  const _SpeciesCard({required this.especie, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FAF5) : Colors.white,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFDDF2E8) : AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(18, 18),
                    painter: _TreeIconPainter(
                      especie.tipoArbol,
                      selected ? AppColors.primary : AppColors.leaf,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      especie.nombre,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: selected ? AppColors.primary : AppColors.ink,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      especie.nombreCientifico,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 11, fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic, color: AppColors.textMuted,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Switch de mantenimiento ──────────────────────────────────────────────────

class _MaintenanceSwitch extends StatelessWidget {
  const _MaintenanceSwitch();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mantenimiento 3 años',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '+15% · Riego, poda y monitoreo mensual',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: p.maintenance,
          onChanged: p.setMaintenance,
          activeThumbColor: AppColors.primary,
          activeTrackColor: const Color(0xFFBFE2CC),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.line,
        ),
      ],
    );
  }
}

// ─── Tarjeta de resumen ───────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final VoidCallback onSubmit;
  const _SummaryCard({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera oscura
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.forest, AppColors.forestDeep],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ESTIMADO',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    letterSpacing: 11 * 0.12,
                    color: AppColors.mint.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _fmtMoney(p.total),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '≈ ${p.co2Anio.toStringAsFixed(1)} t CO₂/año',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mint,
                  ),
                ),
              ],
            ),
          ),
          // Cuerpo con filas
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SummaryRow('Árboles',       _fmtInt(p.trees)),
                _SummaryRow('Tipo',          p.tipo.label),
                _SummaryRow('Especie',       p.especieSeleccionada.nombre),
                _SummaryRow('Precio/árbol',  formatCOP(p.precioPorArbol)),
                _SummaryRow('Subtotal',      _fmtMoney(p.subtotal)),
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.line),
                const SizedBox(height: 10),
                _SummaryRow(
                  'Mantenimiento 3 años',
                  p.maintenance ? '+${_fmtMoney(p.maintenanceCost)}' : '—',
                  valueColor: p.maintenance ? AppColors.primary : AppColors.textSubtle,
                ),
                const SizedBox(height: 12),
                _SummaryRow('Total', _fmtMoney(p.total), bold: true),
                const SizedBox(height: 20),
                _QuoteButton(onPressed: onSubmit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final vColor = valueColor ?? (bold ? AppColors.ink : AppColors.textSubtle);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: bold ? AppColors.ink : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: bold ? 15 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: vColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _QuoteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.28),
        ),
        child: Text(
          'Solicitar cotización',
          style: GoogleFonts.hankenGrotesk(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Label de sección ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.hankenGrotesk(
        fontSize: 11, fontWeight: FontWeight.w600,
        letterSpacing: 11 * 0.08, color: AppColors.textSubtle,
      ),
    );
  }
}

// ─── Tree icon painter ────────────────────────────────────────────────────────

class _TreeIconPainter extends CustomPainter {
  final TipoArbol tipo;
  final Color color;
  const _TreeIconPainter(this.tipo, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final fill = Paint()..color = color..style = PaintingStyle.fill;

    switch (tipo) {
      case TipoArbol.broad:
        canvas.drawRRect(RRect.fromLTRBR(10, 16, 14, 23, const Radius.circular(1.5)), fill);
        canvas.drawOval(const Rect.fromLTWH(3, 2, 18, 15), fill);

      case TipoArbol.conical:
        canvas.drawRRect(RRect.fromLTRBR(10.5, 17, 13.5, 23, const Radius.circular(1.5)), fill);
        canvas.drawPath(Path()..moveTo(12, 2)..lineTo(21, 17)..lineTo(3, 17)..close(), fill);

      case TipoArbol.palm:
        final sp = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 2.5;
        canvas.drawPath(
          Path()..moveTo(12, 23)..cubicTo(10.5, 19, 12.5, 15, 14, 11),
          sp,
        );
        sp.strokeWidth = 1.8;
        for (final d in [
          [14.0, 11.0, 22.0, 5.0],
          [14.0, 11.0,  6.0, 5.0],
          [14.0, 11.0, 18.0, 3.0],
          [14.0, 11.0, 10.0, 3.0],
          [14.0, 11.0, 14.0, 2.0],
        ]) {
          canvas.drawLine(Offset(d[0], d[1]), Offset(d[2], d[3]), sp);
        }
        canvas.drawCircle(const Offset(14, 11), 2.5, fill);
    }
  }

  @override
  bool shouldRepaint(_TreeIconPainter old) => old.tipo != tipo || old.color != color;
}
