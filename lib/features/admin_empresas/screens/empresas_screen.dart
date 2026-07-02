import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api_service.dart';
import '../../../shared/badges/estado_badge.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];

// ─── Modelo local mapeado desde la API ───────────────────────────────────────

class _EmpresaItem {
  final String id;
  final String nombre;
  final String nit;
  final String sector;
  final int empleados;
  final bool activa;

  const _EmpresaItem({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.sector,
    required this.empleados,
    required this.activa,
  });

  factory _EmpresaItem.fromJson(Map<String, dynamic> j) => _EmpresaItem(
        id:       j['id']?.toString() ?? '',
        nombre:   j['name']?.toString() ?? j['nombre']?.toString() ?? 'Empresa',
        nit:      j['nit']?.toString() ?? j['taxId']?.toString() ?? j['tax_id']?.toString() ?? '—',
        sector:   j['sector']?.toString() ?? j['industry']?.toString() ?? '—',
        empleados: (j['employeeCount'] as num?)?.toInt() ??
                   (j['employees'] as num?)?.toInt() ??
                   (j['numberOfEmployees'] as num?)?.toInt() ?? 0,
        activa:   (j['status']?.toString() ?? 'active').toLowerCase() != 'inactive',
      );
}

// ─── Pantalla ─────────────────────────────────────────────────────────────────

class EmpresasScreen extends StatefulWidget {
  const EmpresasScreen({super.key});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  bool _loading = true;
  String? _error;
  List<_EmpresaItem> _empresas = [];
  String _query = '';
  final Set<String> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final raw = await apiService.getEmpresas();
      if (!mounted) return;
      setState(() {
        _empresas = raw.map((e) => _EmpresaItem.fromJson(e as Map<String, dynamic>)).toList();
        _loading  = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error   = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<_EmpresaItem> get _filtered {
    if (_query.isEmpty) return _empresas;
    final q = _query.toLowerCase();
    return _empresas
        .where((e) => e.nombre.toLowerCase().contains(q) || e.nit.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _confirmarEliminacion(_EmpresaItem empresa) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Eliminar empresa?',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        content: Text(
          '¿Estás seguro que deseas eliminar ${empresa.nombre}? Esta acción no se puede deshacer.',
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted, height: 1.4),
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
            child: Text('Cancelar', style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.rechazadoDot,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      setState(() => _deletingIds.add(empresa.id));
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) {
          setState(() {
            _empresas.removeWhere((e) => e.id == empresa.id);
            _deletingIds.remove(empresa.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Empresa eliminada correctamente.',
                style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500, color: Colors.white),
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

  Future<void> _verDetalle(_EmpresaItem empresa) async {
    // Muestra el detalle en un bottom sheet con datos del API si están disponibles
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EmpresaDetalleSheet(empresa: empresa),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientMid, AppColors.bgGradientEnd],
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
                        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textMuted,
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
                    hintStyle: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.placeholder),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSubtle, size: 20),
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
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 40, color: AppColors.textSubtle),
            const SizedBox(height: 14),
            Text(_error!, style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'No hay empresas registradas aún.' : 'No se encontraron empresas.',
          style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(38, 0, 38, 32),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final e = items[i];
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: _deletingIds.contains(e.id)
              ? const SizedBox(width: double.infinity, height: 0)
              : _EmpresaCard(
                  empresa: e,
                  onEliminar: () => _confirmarEliminacion(e),
                  onTap: () => _verDetalle(e),
                ),
        );
      },
    );
  }
}

// ─── Tarjeta de empresa ───────────────────────────────────────────────────────

class _EmpresaCard extends StatefulWidget {
  final _EmpresaItem empresa;
  final VoidCallback onEliminar;
  final VoidCallback onTap;
  const _EmpresaCard({required this.empresa, required this.onEliminar, required this.onTap});

  @override
  State<_EmpresaCard> createState() => _EmpresaCardState();
}

class _EmpresaCardState extends State<_EmpresaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.empresa;
    final (badgeBg, badgeFg, badgeDot, badgeLabel) = e.activa
        ? (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Activa')
        : (const Color(0xFFF2F4F2), AppColors.textSubtle, AppColors.placeholder, 'Inactiva');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
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
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'NIT ${e.nit}',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSubtle,
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
                                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted,
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
                  EstadoBadge.custom(bg: badgeBg, fg: badgeFg, dot: badgeDot, label: badgeLabel),
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
      ),
    );
  }
}

// ─── Bottom sheet de detalle ──────────────────────────────────────────────────

class _EmpresaDetalleSheet extends StatefulWidget {
  final _EmpresaItem empresa;
  const _EmpresaDetalleSheet({required this.empresa});

  @override
  State<_EmpresaDetalleSheet> createState() => _EmpresaDetalleSheetState();
}

class _EmpresaDetalleSheetState extends State<_EmpresaDetalleSheet> {
  bool _loading = true;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await apiService.getEmpresaById(widget.empresa.id);
      if (!mounted) return;
      setState(() { _detail = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.empresa;
    final (badgeBg, badgeFg, badgeDot, badgeLabel) = e.activa
        ? (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Activa')
        : (const Color(0xFFF2F4F2), AppColors.textSubtle, AppColors.placeholder, 'Inactiva');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIT ${e.nit}',
                      style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSubtle),
                    ),
                  ],
                ),
              ),
              EstadoBadge.custom(bg: badgeBg, fg: badgeFg, dot: badgeDot, label: badgeLabel),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ...[
            _SheetRow(icon: Icons.category_outlined,  label: 'Sector',    value: e.sector),
            const SizedBox(height: 12),
            _SheetRow(icon: Icons.people_outline,     label: 'Empleados', value: '${e.empleados}'),
            if (_detail != null) ...[
              const SizedBox(height: 12),
              if (_detail!['email'] != null)
                _SheetRow(icon: Icons.email_outlined, label: 'Email',
                    value: _detail!['email'].toString()),
              if (_detail!['phone'] != null) ...[
                const SizedBox(height: 12),
                _SheetRow(icon: Icons.phone_outlined, label: 'Teléfono',
                    value: _detail!['phone'].toString()),
              ],
              if (_detail!['city'] != null || _detail!['address'] != null) ...[
                const SizedBox(height: 12),
                _SheetRow(icon: Icons.location_on_outlined, label: 'Ubicación',
                    value: _detail!['city']?.toString() ?? _detail!['address']?.toString() ?? '—'),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SheetRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.surfaceMint, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: GoogleFonts.hankenGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSubtle)),
            Text(value,
              style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
          ],
        ),
      ],
    );
  }
}

// ─── Sector chip ─────────────────────────────────────────────────────────────

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
        style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
    );
  }
}
