import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock_admin_data.dart';
import '../../../shared/badges/estado_badge.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];

class EmpresasScreen extends StatefulWidget {
  const EmpresasScreen({super.key});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  late List<EmpresaAdmin> _empresas;
  String _query = '';
  final Set<String> _deletingNits = {};

  @override
  void initState() {
    super.initState();
    _empresas = List.from(mockEmpresas);
  }

  List<EmpresaAdmin> get _filtered {
    if (_query.isEmpty) return _empresas;
    final q = _query.toLowerCase();
    return _empresas
        .where((e) =>
            e.nombre.toLowerCase().contains(q) || e.nit.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _confirmarEliminacion(EmpresaAdmin empresa) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Eliminar empresa?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          '¿Estás seguro que deseas eliminar ${empresa.nombre}? Esta acción no se puede deshacer.',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.line, width: 1.5),
              foregroundColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.rechazadoDot,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      setState(() => _deletingNits.add(empresa.nit));
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) {
          setState(() {
            _empresas.removeWhere((e) => e.nit == empresa.nit);
            _deletingNits.remove(empresa.nit);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Empresa eliminada correctamente.',
                style: GoogleFonts.hankenGrotesk(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.rechazadoDot,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(38, 32, 38, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Empresas', style: AppTextStyles.tituloVista),
                    const SizedBox(height: 6),
                    Text(
                      'Gestión de empresas registradas en GreenNode',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.ink),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Buscar por nombre o NIT…',
                    hintStyle: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      color: AppColors.placeholder,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSubtle,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron empresas.',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(38, 0, 38, 32),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final e = items[i];
                          return AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: _deletingNits.contains(e.nit)
                                ? const SizedBox(width: double.infinity, height: 0)
                                : _EmpresaCard(
                                    empresa: e,
                                    onEliminar: () => _confirmarEliminacion(e),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmpresaCard extends StatefulWidget {
  final EmpresaAdmin empresa;
  final VoidCallback onEliminar;
  const _EmpresaCard({required this.empresa, required this.onEliminar});

  @override
  State<_EmpresaCard> createState() => _EmpresaCardState();
}

class _EmpresaCardState extends State<_EmpresaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.empresa;
    final activa = e.estado == EstadoEmpresa.activa;
    final (badgeBg, badgeFg, badgeDot, badgeLabel) = activa
        ? (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Activa')
        : (const Color(0xFFF2F4F2), AppColors.textSubtle, AppColors.placeholder, 'Inactiva');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? const Color(0xFFBFE2CC) : AppColors.line,
            width: 1,
          ),
          boxShadow: _cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.nombre,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'NIT ${e.nit}',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _SectorChip(e.sector),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline, size: 14, color: AppColors.textSubtle),
                          const SizedBox(width: 4),
                          Text(
                            '${e.empleados} empleados',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EstadoBadge.custom(
                  bg: badgeBg,
                  fg: badgeFg,
                  dot: badgeDot,
                  label: badgeLabel,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: widget.onEliminar,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.rechazadoBg,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: AppColors.rechazadoDot,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectorChip extends StatelessWidget {
  final String label;
  const _SectorChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
