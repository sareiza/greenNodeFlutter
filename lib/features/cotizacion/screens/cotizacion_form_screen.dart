import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/mock_data.dart';
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

class _CotizacionFormView extends StatelessWidget {
  const _CotizacionFormView();

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
            colors: [
              AppColors.bgGradientStart,
              AppColors.bgGradientMid,
              AppColors.bgGradientEnd,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < _bodyRowBreakpoint
                ? 16.0
                : 40.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 34,
              ),
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
                  const _BodyRow(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Cabecera de página ───────────────────────────────────────────────────────

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
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.52,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Estima la inversión de tu bosque corporativo.',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
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
          // Borde izquierdo verde
          Container(width: 3, height: 48, color: AppColors.primary),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Ley 2173',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' · Mínimo 2 árboles por empleado · Res. 1491 de 2025',
                    ),
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
                onTap: () =>
                    context.read<CotizacionFormProvider>().closeLegalBanner(),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
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

/// Breakpoint por debajo del cual el formulario y el resumen se apilan en
/// vertical en lugar de ir lado a lado — a 800px+ ambos comparten fila pero
/// debajo de eso cada columna queda demasiado angosta y el texto se rompe.
const _bodyRowBreakpoint = 700.0;

class _BodyRow extends StatelessWidget {
  const _BodyRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _bodyRowBreakpoint) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_FormColumn(), SizedBox(height: 24), _SummaryCard()],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _FormColumn()),
            SizedBox(width: 24),
            Expanded(flex: 2, child: _SummaryCard()),
          ],
        );
      },
    );
  }
}

// ─── Columna de formulario ────────────────────────────────────────────────────

class _FormColumn extends StatelessWidget {
  const _FormColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormCard(child: _TreesSlider()),
        SizedBox(height: 14),
        _FormCard(child: _TypeChips()),
        SizedBox(height: 14),
        _FormCard(child: _TerritorySection()),
        SizedBox(height: 14),
        _FormCard(child: _MaintenanceSwitch()),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x08102A1C),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
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
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1,
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
            min: 100,
            max: 10000,
            divisions: 198, // paso 50: (10000-100)/50
            onChanged: (v) => p.setTrees(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '100',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  color: AppColors.textSubtle,
                ),
              ),
              Text(
                '10,000',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  color: AppColors.textSubtle,
                ),
              ),
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
  const _TypeChip({
    required this.tipo,
    required this.selected,
    required this.onTap,
  });

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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${tipo.multLabel} · ${tipo.precioLabel}',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.75)
                      : AppColors.textMuted,
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
  const _TerritorySection();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Territorio'),
        const SizedBox(height: 10),
        _TerritoryDropdown(
          value: p.territorio,
          onChanged: (z) => p.setTerritorio(z!),
        ),
        const SizedBox(height: 22),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.aprobadoText,
                ),
              ),
            ),
          ],
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

class _TerritoryDropdown extends StatelessWidget {
  final ZonaEcologica value;
  final ValueChanged<ZonaEcologica?> onChanged;
  const _TerritoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
    );
    return DropdownButtonFormField<ZonaEcologica>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceTint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dropdownColor: Colors.white,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textMuted,
      ),
      style: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
      items: ZonaEcologica.values
          .map(
            (z) => DropdownMenuItem(
              value: z,
              child: Text(z.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
    );
  }
}

// ─── Grid de especies ─────────────────────────────────────────────────────────

class _SpeciesGrid extends StatelessWidget {
  final List<EspecieCalc> especies;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _SpeciesGrid({
    required this.especies,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final colW = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
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
  const _SpeciesCard({
    required this.especie,
    required this.selected,
    required this.onTap,
  });

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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFDDF2E8)
                      : AppColors.surfaceMint,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.primary : AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      especie.nombreCientifico,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '+15% · Riego, poda y monitoreo mensual',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
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
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12102A1C),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.forest, AppColors.forestDeep],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ESTIMADO',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 11 * 0.12,
                    color: AppColors.mint.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _fmtMoney(p.total),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '≈ ${p.co2Anio.toStringAsFixed(1)} t CO₂/año',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mint,
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
                _SummaryRow('Árboles', _fmtInt(p.trees)),
                _SummaryRow('Tipo', p.tipo.label),
                _SummaryRow('Especie', p.especieSeleccionada.nombre),
                _SummaryRow(
                  'Precio/árbol',
                  formatCOP(p.precioPorArbol),
                ),
                _SummaryRow('Subtotal', _fmtMoney(p.subtotal)),
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.line),
                const SizedBox(height: 10),
                _SummaryRow(
                  'Mantenimiento 3 años',
                  p.maintenance ? '+${_fmtMoney(p.maintenanceCost)}' : '—',
                  valueColor: p.maintenance
                      ? AppColors.primary
                      : AppColors.textSubtle,
                ),
                const SizedBox(height: 12),
                _SummaryRow('Total', _fmtMoney(p.total), bold: true),
                const SizedBox(height: 20),
                const _QuoteButton(),
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
  const _SummaryRow(
    this.label,
    this.value, {
    this.bold = false,
    this.valueColor,
  });

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
  const _QuoteButton();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CotizacionFormProvider>();

    if (p.quoteSent) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.aprobadoBg,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.leaf,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Cotización enviada',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.aprobadoText,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => context.read<CotizacionFormProvider>().sendQuote(),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.28),
        ),
        child: Text(
          'Solicitar cotización',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
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
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 11 * 0.08,
        color: AppColors.textSubtle,
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
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (tipo) {
      case TipoArbol.broad:
        canvas.drawRRect(
          RRect.fromLTRBR(10, 16, 14, 23, const Radius.circular(1.5)),
          fill,
        );
        canvas.drawOval(const Rect.fromLTWH(3, 2, 18, 15), fill);

      case TipoArbol.conical:
        canvas.drawRRect(
          RRect.fromLTRBR(10.5, 17, 13.5, 23, const Radius.circular(1.5)),
          fill,
        );
        canvas.drawPath(
          Path()
            ..moveTo(12, 2)
            ..lineTo(21, 17)
            ..lineTo(3, 17)
            ..close(),
          fill,
        );

      case TipoArbol.palm:
        final sp = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 2.5;
        canvas.drawPath(
          Path()
            ..moveTo(12, 23)
            ..cubicTo(10.5, 19, 12.5, 15, 14, 11),
          sp,
        );
        sp.strokeWidth = 1.8;
        for (final d in [
          [14.0, 11.0, 22.0, 5.0],
          [14.0, 11.0, 6.0, 5.0],
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
  bool shouldRepaint(_TreeIconPainter old) =>
      old.tipo != tipo || old.color != color;
}
