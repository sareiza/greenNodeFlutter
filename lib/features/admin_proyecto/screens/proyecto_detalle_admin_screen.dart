import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api_service.dart';
import '../../../shared/badges/estado_badge.dart';

const _cardShadow = [
  BoxShadow(color: Color(0x12102A1C), blurRadius: 24, offset: Offset(0, 8)),
];

// ─── Modelos locales ──────────────────────────────────────────────────────────

enum _EstadoP { enProgreso, completado, cancelado }

class _EvidenciaItem {
  final String id;
  final String? imageUrl;
  final String estadoIA;
  final String fecha;
  final double? aiConfidence;
  final int?    aiEstimatedTrees;
  final String? aiObservations;

  const _EvidenciaItem({
    required this.id,
    this.imageUrl,
    required this.estadoIA,
    required this.fecha,
    this.aiConfidence,
    this.aiEstimatedTrees,
    this.aiObservations,
  });

  factory _EvidenciaItem.fromJson(Map<String, dynamic> j) {
    final validated = j['aiValidated'] as bool? ?? false;
    final estado = validated ? 'validated'
        : (j['status']?.toString() ?? 'pending').toLowerCase();
    return _EvidenciaItem(
      id:              j['id']?.toString() ?? '',
      imageUrl:        j['photoUrl']?.toString() ?? j['imageUrl']?.toString() ??
                       j['fileUrl']?.toString()  ?? j['url']?.toString(),
      estadoIA:        estado,
      fecha:           _fmt(j['createdAt']?.toString()),
      aiConfidence:    (j['aiConfidence'] as num?)?.toDouble(),
      aiEstimatedTrees:(j['aiEstimatedTrees'] as num?)?.toInt(),
      aiObservations:  j['aiObservations']?.toString(),
    );
  }

  bool get pendiente => estadoIA == 'pending';
}

// ─── Helpers visuales ─────────────────────────────────────────────────────────

String _fmt(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso);
    const m = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return iso.split('T').first;
  }
}

(Color bg, Color fg, Color dot, String label) _estadoProyectoVis(_EstadoP e) => switch (e) {
      _EstadoP.enProgreso => (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'En progreso'),
      _EstadoP.completado => (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Completado'),
      _EstadoP.cancelado  => (AppColors.rechazadoBg, AppColors.rechazadoText, AppColors.rechazadoDot, 'Cancelado'),
    };

(Color bg, Color fg, Color dot, String label) _estadoIAVis(String status) => switch (status) {
      'approved' || 'validated' || 'validado' =>
        (AppColors.aprobadoBg, AppColors.aprobadoText, AppColors.aprobadoDot, 'Validado IA'),
      'rejected' || 'rechazado' =>
        (AppColors.rechazadoBg, AppColors.rechazadoText, AppColors.rechazadoDot, 'Rechazado'),
      'processing' || 'validating' =>
        (AppColors.enRevisionBg, AppColors.enRevisionText, AppColors.enRevisionDot, 'Validando IA…'),
      _ => (AppColors.pendienteBg, AppColors.pendienteText, AppColors.pendienteDot, 'Pendiente'),
    };

_EstadoP _mapEstadoP(String status) => switch (status.toLowerCase()) {
      'completed' || 'completado'                      => _EstadoP.completado,
      'cancelled' || 'canceled' || 'cancelado'         => _EstadoP.cancelado,
      _                                                => _EstadoP.enProgreso,
    };

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
  State<ProyectoDetalleAdminScreen> createState() => _ProyectoDetalleAdminScreenState();
}

class _ProyectoDetalleAdminScreenState extends State<ProyectoDetalleAdminScreen> {
  // ── Carga inicial ──────────────────────────────────────────────────────────
  bool _loading = true;
  String? _error;

  // ── Datos del proyecto ─────────────────────────────────────────────────────
  Map<String, dynamic>? _proyecto;
  _EstadoP _estado = _EstadoP.enProgreso;
  double _avance = 0.0;
  int _totalArboles = 1;
  late TextEditingController _marcoCtrl;
  bool _editandoMarco = false;

  // ── Evidencias ─────────────────────────────────────────────────────────────
  List<_EvidenciaItem> _evidencias = [];
  bool _subiendo = false;

  // ── Guardar progreso ───────────────────────────────────────────────────────
  bool _savingProgress = false;

  @override
  void initState() {
    super.initState();
    _marcoCtrl = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _marcoCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        apiService.getProyectoById(widget.id),
        apiService.getEvidencias(widget.id).catchError((_) => <dynamic>[]),
      ]);

      final proyecto    = results[0] as Map<String, dynamic>;
      final evidRaw     = results[1] as List<dynamic>;

      if (!mounted) return;
      setState(() {
        _proyecto  = proyecto;
        _estado    = _mapEstadoP(proyecto['status']?.toString() ?? '');
        final pct     = (proyecto['progressPercentage'] as num?)?.toDouble() ??
                        (proyecto['progress'] as num?)?.toDouble() ?? 0.0;
        _avance       = pct > 1.0 ? pct / 100.0 : pct;
        _totalArboles = (proyecto['numberOfTrees'] as num?)?.toInt() ?? 1;
        _marcoCtrl.text = proyecto['logicalFramework']?.toString() ??
            proyecto['marcoLogico']?.toString() ??
            proyecto['description']?.toString() ?? '';

        // Usar evidencias embebidas del proyecto si el endpoint separado está vacío
        final embeddedEvid = proyecto['evidences'];
        final evidList = (embeddedEvid is List && embeddedEvid.isNotEmpty)
            ? embeddedEvid
            : evidRaw;
        // ignore: avoid_print
        if (evidList.isNotEmpty) print('[EVID KEYS]: ${(evidList.first as Map).keys.toList()}');
        _evidencias = evidList
            .map((e) => _EvidenciaItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error   = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _recargarEvidencias() async {
    try {
      final raw = await apiService.getEvidencias(widget.id);
      if (!mounted) return;
      setState(() {
        _evidencias = raw.map((e) => _EvidenciaItem.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (_) {}
  }

  // ── Guardar progreso ───────────────────────────────────────────────────────

  Future<void> _guardarCambios() async {
    setState(() => _savingProgress = true);
    try {
      final validatedCount = (_avance * _totalArboles).round();
      await apiService.actualizarProgreso(widget.id, validatedCount);
      if (!mounted) return;
      _showSnackBar('Progreso actualizado correctamente.', AppColors.primary);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), AppColors.rechazadoDot);
    } finally {
      if (mounted) setState(() => _savingProgress = false);
    }
  }

  // ── Marco lógico ──────────────────────────────────────────────────────────

  void _guardarMarco() {
    setState(() => _editandoMarco = false);
    _showSnackBar('Marco lógico guardado localmente. Pendiente de endpoint en el servidor.', AppColors.primary);
  }

  // ── Subida de evidencias ──────────────────────────────────────────────────

  Future<void> _mostrarSheetSubida() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al abrir selector: $e', AppColors.rechazadoDot);
      return;
    }

    if (result == null || result.files.isEmpty || !mounted) return;

    final picked = result.files.first;
    final bytes  = picked.bytes;
    final name   = picked.name;

    if (bytes == null) {
      _showSnackBar('No se pudo leer el archivo.', AppColors.rechazadoDot);
      return;
    }

    setState(() => _subiendo = true);

    try {
      await apiService.subirEvidencia(widget.id, bytes, name);
      if (!mounted) return;
      _showSnackBar('Evidencia subida. Validando con IA…', AppColors.primary);
      // Polling: el backend procesa la IA en background; refrescamos hasta 3 veces
      await _recargarEvidencias();
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        if (!_evidencias.any((e) => e.pendiente)) break;
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        await _recargarEvidencias();
      }
      if (mounted) _showSnackBar('Evidencia procesada.', AppColors.primary);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), AppColors.rechazadoDot);
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  // ── Utilidades ─────────────────────────────────────────────────────────────

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (_loading || _error != null)
          ? null
          : FloatingActionButton(
              onPressed: _mostrarSheetSubida,
              backgroundColor: AppColors.primary,
              tooltip: 'Subir evidencia',
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientMid, AppColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(child: _buildBody()),
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
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    if (_proyecto == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Proyecto no encontrado.',
                style: GoogleFonts.hankenGrotesk(fontSize: 15, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/admin/proyectos'),
              child: Text('Volver', style: GoogleFonts.hankenGrotesk(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    final p     = _proyecto!;
    final nombre  = p['name']?.toString() ?? p['nombre']?.toString() ?? 'Proyecto';
    final empresa = p['companyName']?.toString() ?? p['empresa']?.toString() ?? '—';
    final (_, fg, dot, label) = _estadoProyectoVis(_estado);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(38, 32, 38, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Volver ───────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go('/admin/proyectos'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textSubtle),
                const SizedBox(width: 4),
                Text('Volver a proyectos',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ───────────────────────────────────────────────────────
          Text(nombre,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.15)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.business_outlined, size: 14, color: AppColors.textSubtle),
              const SizedBox(width: 5),
              Text(empresa,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
              const SizedBox(width: 12),
              EstadoBadge.custom(bg: _estadoProyectoVis(_estado).$1, fg: fg, dot: dot, label: label),
            ],
          ),
          const SizedBox(height: 28),

          // ── Estado & avance ───────────────────────────────────────────────
          _SectionCard(
            title: 'Estado del proyecto',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSubtle)),
                const SizedBox(height: 8),
                _EstadoDropdown(value: _estado, onChanged: (v) => setState(() => _estado = v)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Avance',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSubtle)),
                    const Spacer(),
                    Text('${(_avance * 100).round()}%',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.line,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: _avance,
                    min: 0, max: 1, divisions: 100,
                    onChanged: (v) => setState(() => _avance = v),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _savingProgress ? null : _guardarCambios,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    child: _savingProgress
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Guardar cambios',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Evidencias ────────────────────────────────────────────────────
          _SectionCard(
            title: 'Evidencias',
            trailing: Text('${_evidencias.length} fotos',
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSubtle)),
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
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                                ),
                                const SizedBox(width: 10),
                                Text('Subiendo evidencia…',
                                    style: GoogleFonts.hankenGrotesk(
                                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: const LinearProgressIndicator(
                                minHeight: 5,
                                backgroundColor: AppColors.line,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                          const Icon(Icons.photo_library_outlined, size: 40, color: AppColors.placeholder),
                          const SizedBox(height: 8),
                          Text('Sin evidencias aún',
                              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15,
                    ),
                    itemCount: _evidencias.length,
                    itemBuilder: (context, i) => _EvidenciaCard(_evidencias[i], i),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Marco lógico ──────────────────────────────────────────────────
          _SectionCard(
            title: 'Marco Lógico',
            trailing: _editandoMarco
                ? null
                : GestureDetector(
                    onTap: () => setState(() => _editandoMarco = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceMint, borderRadius: BorderRadius.circular(8)),
                      child: Text('Editar',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
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
                        style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.ink, height: 1.55),
                        decoration: InputDecoration(
                          filled: true, fillColor: AppColors.surfaceTint,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _guardarMarco,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Guardar',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  )
                : Text(
                    _marcoCtrl.text.isEmpty ? 'Sin marco lógico registrado.' : _marcoCtrl.text,
                    style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textMuted, height: 1.6),
                  ),
          ),
        ],
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
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
              if (trailing != null) ...[const Spacer(), trailing!],
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
  final _EstadoP value;
  final ValueChanged<_EstadoP> onChanged;
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
      child: DropdownButton<_EstadoP>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        isDense: true,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items: _EstadoP.values.map((e) {
          final (_, fg, dot, label) = _estadoProyectoVis(e);
          return DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                Text(label,
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

// ─── Tarjeta de evidencia ─────────────────────────────────────────────────────

class _EvidenciaCard extends StatelessWidget {
  final _EvidenciaItem evidencia;
  final int index;
  const _EvidenciaCard(this.evidencia, this.index);

  @override
  Widget build(BuildContext context) {
    final colors  = _photoGradients[index % _photoGradients.length];
    final (bg, fg, dot, label) = _estadoIAVis(evidencia.estadoIA);

    return Stack(
      children: [
        // Fondo: imagen real o gradiente placeholder
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: evidencia.imageUrl != null
                ? Image.network(
                    evidencia.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _GradientBox(colors: colors),
                  )
                : _GradientBox(colors: colors),
          ),
        ),
        Positioned(top: 8, left: 8,
            child: EstadoBadge.custom(bg: bg, fg: fg, dot: dot, label: label)),
        Positioned(
          bottom: 8, right: 8,
          child: Text(evidencia.fecha,
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 10, fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75))),
        ),
      ],
    );
  }
}

class _GradientBox extends StatelessWidget {
  final List<Color> colors;
  const _GradientBox({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors,
        ),
      ),
      child: Center(
        child: Icon(Icons.eco_outlined, size: 42, color: Colors.white.withValues(alpha: 0.18)),
      ),
    );
  }
}

