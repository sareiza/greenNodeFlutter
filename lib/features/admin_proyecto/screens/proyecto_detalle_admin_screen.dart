import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/mock_admin_data.dart';
import '../../../shared/badges/estado_badge.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];

// ─── Helpers visuales ─────────────────────────────────────────────────────────

(Color bg, Color fg, Color dot, String label) _estadoProyectoVis(
    EstadoProyectoAdmin e) =>
    switch (e) {
      EstadoProyectoAdmin.enProgreso =>
        (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'En progreso'),
      EstadoProyectoAdmin.completado =>
        (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Completado'),
      EstadoProyectoAdmin.cancelado =>
        (AppColors.rechazadoBg, AppColors.rechazadoText, AppColors.rechazadoDot, 'Cancelado'),
    };

(Color bg, Color fg, Color dot, String label) _estadoIAVis(EstadoIA e) =>
    switch (e) {
      EstadoIA.validado =>
        (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Validado IA'),
      EstadoIA.pendiente =>
        (AppColors.pendienteBg, AppColors.pendienteText, AppColors.pendienteDot, 'Pendiente'),
      EstadoIA.rechazado =>
        (AppColors.rechazadoBg, AppColors.rechazadoText, AppColors.rechazadoDot, 'Rechazado'),
      EstadoIA.validandoIA =>
        (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'Validando IA…'),
    };

String _mesCorto(int m) => const [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ][m - 1];

// Gradientes placeholder para las fotos de evidencia
const _photoGradients = [
  [Color(0xFF1A3A2A), Color(0xFF2D5A3D)],
  [Color(0xFF0E2C1E), Color(0xFF1B4332)],
  [Color(0xFF163327), Color(0xFF234035)],
  [Color(0xFF1E3A2A), Color(0xFF15462F)],
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProyectoDetalleAdminScreen extends StatefulWidget {
  final String id;
  const ProyectoDetalleAdminScreen({super.key, required this.id});

  @override
  State<ProyectoDetalleAdminScreen> createState() =>
      _ProyectoDetalleAdminScreenState();
}

class _ProyectoDetalleAdminScreenState
    extends State<ProyectoDetalleAdminScreen> {
  ProyectoAdminDetalle? _proyecto;
  late EstadoProyectoAdmin _estado;
  late double _avance;
  late List<EvidenciaAdmin> _evidencias;
  late TextEditingController _marcoCtrl;
  bool _editandoMarco = false;
  bool _subiendo = false;

  @override
  void initState() {
    super.initState();
    _proyecto =
        mockProyectosAdmin.where((p) => p.id == widget.id).firstOrNull;
    if (_proyecto != null) {
      _estado = _proyecto!.estado;
      _avance = _proyecto!.avance;
      _evidencias = List.from(_proyecto!.evidencias);
      _marcoCtrl = TextEditingController(text: _proyecto!.marcoLogico);
    } else {
      _marcoCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _marcoCtrl.dispose();
    super.dispose();
  }

  // ── Estado & avance ────────────────────────────────────────────────────────

  void _guardarCambios() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cambios guardados correctamente.',
          style: GoogleFonts.hankenGrotesk(
              fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Marco lógico ──────────────────────────────────────────────────────────

  void _guardarMarco() {
    setState(() => _editandoMarco = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Marco lógico actualizado.',
          style: GoogleFonts.hankenGrotesk(
              fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Subida evidencia ──────────────────────────────────────────────────────

  void _mostrarSheetSubida() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SubirEvidenciaSheet(
        onSeleccion: (fuente) {
          Navigator.of(ctx).pop();
          _iniciarSubida(fuente);
        },
      ),
    );
  }

  Future<void> _iniciarSubida(String fuente) async {
    if (!mounted) return;
    setState(() => _subiendo = true);

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final hoy = DateTime.now();
    final nueva = EvidenciaAdmin(
      id: 'EV-${hoy.millisecondsSinceEpoch}',
      estadoIA: EstadoIA.validandoIA,
      fecha: '${hoy.day} ${_mesCorto(hoy.month)} ${hoy.year}',
    );

    setState(() {
      _subiendo = false;
      _evidencias.insert(0, nueva);
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() => nueva.estadoIA = EstadoIA.validado);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_proyecto == null) {
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
          child: Center(
            child: Text(
              'Proyecto no encontrado.',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    final p = _proyecto!;
    final (_, fg, dot, label) = _estadoProyectoVis(_estado);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarSheetSubida,
        backgroundColor: AppColors.primary,
        tooltip: 'Subir evidencia',
        child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(38, 32, 38, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Volver ────────────────────────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/admin/proyectos'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14, color: AppColors.textSubtle),
                      const SizedBox(width: 4),
                      Text(
                        'Volver a proyectos',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Header ────────────────────────────────────────────────
                Text(
                  p.nombre,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.business_outlined,
                        size: 14, color: AppColors.textSubtle),
                    const SizedBox(width: 5),
                    Text(
                      p.empresa,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSubtle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    EstadoBadge.custom(
                      bg: _estadoProyectoVis(_estado).$1,
                      fg: fg,
                      dot: dot,
                      label: label,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Estado del proyecto ───────────────────────────────────
                _SectionCard(
                  title: 'Estado del proyecto',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSubtle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _EstadoDropdown(
                        value: _estado,
                        onChanged: (v) => setState(() => _estado = v),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Avance',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSubtle,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(_avance * 100).round()}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 9),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 18),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.line,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(alpha: 0.15),
                        ),
                        child: Slider(
                          value: _avance,
                          min: 0,
                          max: 1,
                          divisions: 100,
                          onChanged: (v) => setState(() => _avance = v),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _guardarCambios,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Text(
                            'Guardar cambios',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Evidencias ────────────────────────────────────────────
                _SectionCard(
                  title: 'Evidencias',
                  trailing: Text(
                    '${_evidencias.length} fotos',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Barra de progreso de subida
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: _subiendo
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Subiendo evidencia…',
                                        style: GoogleFonts.hankenGrotesk(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      minHeight: 5,
                                      backgroundColor: AppColors.line,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (_evidencias.isEmpty && !_subiendo)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.photo_library_outlined,
                                    size: 40, color: AppColors.placeholder),
                                const SizedBox(height: 8),
                                Text(
                                  'Sin evidencias aún',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: _evidencias.length,
                          itemBuilder: (context, i) =>
                              _EvidenciaCard(_evidencias[i], i),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Marco Lógico ──────────────────────────────────────────
                _SectionCard(
                  title: 'Marco Lógico',
                  trailing: _editandoMarco
                      ? null
                      : GestureDetector(
                          onTap: () => setState(() => _editandoMarco = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Editar',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                  child: _editandoMarco
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _marcoCtrl,
                              maxLines: null,
                              minLines: 5,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 14,
                                color: AppColors.ink,
                                height: 1.55,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceTint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.inputBorder, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.inputBorder, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _guardarMarco,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Guardar',
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _marcoCtrl.text,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.6,
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

// ─── Sección tarjeta ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Dropdown estado ──────────────────────────────────────────────────────────

class _EstadoDropdown extends StatelessWidget {
  final EstadoProyectoAdmin value;
  final ValueChanged<EstadoProyectoAdmin> onChanged;
  const _EstadoDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<EstadoProyectoAdmin>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        isDense: true,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items: EstadoProyectoAdmin.values.map((e) {
          final (_, fg, dot, label) = _estadoProyectoVis(e);
          return DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

// ─── Tarjeta de evidencia ─────────────────────────────────────────────────────

class _EvidenciaCard extends StatelessWidget {
  final EvidenciaAdmin evidencia;
  final int index;
  const _EvidenciaCard(this.evidencia, this.index);

  @override
  Widget build(BuildContext context) {
    final colors = _photoGradients[index % _photoGradients.length];
    final (bg, fg, dot, label) = _estadoIAVis(evidencia.estadoIA);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.eco_outlined,
              size: 42,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: EstadoBadge.custom(bg: bg, fg: fg, dot: dot, label: label),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Text(
            evidencia.fecha,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom sheet subida ──────────────────────────────────────────────────────

class _SubirEvidenciaSheet extends StatelessWidget {
  final ValueChanged<String> onSeleccion;
  const _SubirEvidenciaSheet({required this.onSeleccion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            'Subir evidencia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Selecciona la fuente de la imagen.',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          _SheetOption(
            icon: Icons.camera_alt_outlined,
            label: 'Cámara',
            onTap: () => onSeleccion('camara'),
          ),
          const SizedBox(height: 10),
          _SheetOption(
            icon: Icons.photo_library_outlined,
            label: 'Galería',
            onTap: () => onSeleccion('galeria'),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceMint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.placeholder),
          ],
        ),
      ),
    );
  }
}
