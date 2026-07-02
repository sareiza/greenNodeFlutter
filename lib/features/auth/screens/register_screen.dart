import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api_service.dart';
import '../../../shared/widgets/greennode_logo.dart';
import '../providers/auth_provider.dart';
import '../providers/register_provider.dart';

const _labelColor    = Color(0xFF28392F);
const _termsTextColor = Color(0xFF3E4F44);
const _termsBoxIdle  = Color(0xFFCBD8CF);

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterProvider(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _companyCtrl  = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ─── Registro real contra el API ──────────────────────────────────────────

  Future<void> _doRegister() async {
    final provider = context.read<RegisterProvider>();

    setState(() => _loading = true);
    try {
      await apiService.register({
        'companyName': provider.company,
        'email':       provider.empEmail,
        'password':    provider.password,
        'phone':       provider.phone,
        'sector':      provider.sector,
      });

      // El registro no devuelve token — hacemos login automático
      await apiService.login(provider.empEmail, provider.password);

      if (!mounted) return;

      context.read<AuthProvider>().loginDirecto(email: provider.empEmail, sector: provider.sector);

      context.go('/proyecto');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.hankenGrotesk(
                fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: AppColors.rechazadoDot,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: _buildForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final provider = context.watch<RegisterProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: GreenNodeLogo(size: 28)),
        const SizedBox(height: 24),
        Text(
          'Registra tu empresa',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.56,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text('Tres pasos rápidos para empezar a plantar.', style: AppTextStyles.cuerpo),
        const SizedBox(height: 28),

        // ── Barra de progreso ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0, end: provider.progress),
                  builder: (_, value, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              provider.stepLabel,
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Contenido del paso actual ───────────────────────────────────────
        if (provider.step == 1) _buildStep1(provider),
        if (provider.step == 2) _buildStep2(provider),
        if (provider.step == 3) _buildStep3(provider),

        const SizedBox(height: 28),

        // ── Botones Atrás / Continuar|Crear cuenta ─────────────────────────
        Row(
          children: [
            Opacity(
              opacity: provider.canGoBack ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !provider.canGoBack || _loading,
                child: OutlinedButton(
                  onPressed: provider.prevStep,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: Text(
                    'Atrás',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 15, fontWeight: FontWeight.w600, color: _labelColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.26),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : provider.showContinue
                          ? provider.nextStep
                          : _doRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: _loading && !provider.showContinue
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          provider.showContinue ? 'Continuar' : 'Crear cuenta',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              '¿Ya tienes cuenta? ',
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMuted),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                'Inicia sesión',
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Pasos ────────────────────────────────────────────────────────────────

  Widget _buildStep1(RegisterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Nombre de la empresa'),
        const SizedBox(height: 7),
        TextField(
          controller: _companyCtrl,
          onChanged: provider.setCompany,
          style: _inputStyle,
          decoration: const InputDecoration(
            filled: true, fillColor: Colors.white, hintText: 'Bosques S.A.',
          ),
        ),
        const SizedBox(height: 18),
        _label('Teléfono'),
        const SizedBox(height: 7),
        TextField(
          controller: _phoneCtrl,
          onChanged: provider.setPhone,
          keyboardType: TextInputType.phone,
          style: _inputStyle,
          decoration: const InputDecoration(
            filled: true, fillColor: Colors.white, hintText: '+57 300 000 0000',
          ),
        ),
        const SizedBox(height: 18),
        _label('Sector'),
        const SizedBox(height: 7),
        _StyledDropdown<String>(
          value: provider.sector,
          items: RegisterProvider.sectors.map((key) => DropdownMenuItem(
            value: key,
            child: Text(RegisterProvider.sectorLabels[key]!, style: _inputStyle),
          )).toList(),
          onChanged: (v) { if (v != null) provider.setSector(v); },
        ),
      ],
    );
  }

  Widget _buildStep2(RegisterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Email corporativo'),
        const SizedBox(height: 7),
        TextField(
          controller: _emailCtrl,
          onChanged: provider.setEmpEmail,
          keyboardType: TextInputType.emailAddress,
          style: _inputStyle,
          decoration: const InputDecoration(
            filled: true, fillColor: Colors.white, hintText: 'ops@empresa.com',
          ),
        ),
        const SizedBox(height: 18),
        _label('Número de empleados'),
        const SizedBox(height: 7),
        _StyledDropdown<String>(
          value: provider.employees,
          items: RegisterProvider.employeeRanges.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: _inputStyle),
          )).toList(),
          onChanged: (v) { if (v != null) provider.setEmployees(v); },
        ),
      ],
    );
  }

  Widget _buildStep3(RegisterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Contraseña'),
        const SizedBox(height: 7),
        TextField(
          controller: _passwordCtrl,
          onChanged: provider.setPassword,
          obscureText: true,
          style: _inputStyle,
          decoration: const InputDecoration(
            filled: true, fillColor: Colors.white, hintText: '••••••••',
          ),
        ),
        const SizedBox(height: 18),
        _label('Confirmar contraseña'),
        const SizedBox(height: 7),
        TextField(
          controller: _confirmCtrl,
          onChanged: provider.setConfirmPassword,
          obscureText: true,
          style: _inputStyle,
          decoration: const InputDecoration(
            filled: true, fillColor: Colors.white, hintText: '••••••••',
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: provider.toggleTerms,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(top: 1),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: provider.acceptTerms ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: provider.acceptTerms ? AppColors.primary : _termsBoxIdle,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: provider.acceptTerms
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14, fontWeight: FontWeight.w400,
                        height: 1.5, color: _termsTextColor),
                    children: [
                      const TextSpan(text: 'Acepto los '),
                      TextSpan(
                        text: 'Términos',
                        style: TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' y la '),
                      TextSpan(
                        text: 'Política de privacidad',
                        style: TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.hankenGrotesk(
            fontSize: 13, fontWeight: FontWeight.w600, color: _labelColor),
      );

  TextStyle get _inputStyle => GoogleFonts.hankenGrotesk(
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink);
}

// ─── Dropdown estilizado (evita DropdownButtonFormField deprecado) ────────────

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inputBorder, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSubtle),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
