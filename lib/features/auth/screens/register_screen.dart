import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/greennode_logo.dart';
import '../providers/auth_provider.dart';
import '../providers/register_provider.dart';

/// Valores puntuales del mockup que no forman parte de los Design Tokens
/// del README pero aparecen en la referencia HTML de la sección
/// "2. Registrar empresa".
const _labelColor = Color(0xFF28392F);
const _termsTextColor = Color(0xFF3E4F44);
const _termsBoxIdle = Color(0xFFCBD8CF);
const _logoutBorder = Color(0xFFBFE2CC);

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
  final _companyController = TextEditingController();
  final _empEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _empEmailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registered = context.select<RegisterProvider, bool>((p) => p.registered);

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
              child: registered ? const _SuccessState() : _buildForm(context),
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
        Text(
          'Tres pasos rápidos para empezar a plantar.',
          style: AppTextStyles.cuerpo,
        ),
        const SizedBox(height: 28),
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
                  builder: (context, value, child) => FractionallySizedBox(
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (provider.step == 1) _buildStep1(provider),
        if (provider.step == 2) _buildStep2(provider),
        if (provider.step == 3) _buildStep3(provider),
        const SizedBox(height: 28),
        Row(
          children: [
            Opacity(
              opacity: provider.canGoBack ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !provider.canGoBack,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _labelColor,
                    ),
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
                  onPressed: provider.showContinue
                      ? provider.nextStep
                      : () {
                          provider.register();
                          context.read<AuthProvider>().loginDirecto(email: provider.empEmail);
                          final router = GoRouter.of(context);
                          Future.delayed(const Duration(milliseconds: 900), () {
                            if (mounted) router.go('/proyecto');
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: Text(
                    provider.showContinue ? 'Continuar' : 'Crear cuenta',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                'Inicia sesión',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep1(RegisterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Nombre de la empresa'),
        const SizedBox(height: 7),
        TextField(
          controller: _companyController,
          onChanged: provider.setCompany,
          style: _inputTextStyle,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Bosques S.A.',
          ),
        ),
        const SizedBox(height: 18),
        _label('Sector'),
        const SizedBox(height: 7),
        _dropdown(
          value: provider.sector,
          items: RegisterProvider.sectors,
          onChanged: provider.setSector,
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
          controller: _empEmailController,
          onChanged: provider.setEmpEmail,
          keyboardType: TextInputType.emailAddress,
          style: _inputTextStyle,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'ops@empresa.com',
          ),
        ),
        const SizedBox(height: 18),
        _label('Número de empleados'),
        const SizedBox(height: 7),
        _dropdown(
          value: provider.employees,
          items: RegisterProvider.employeeRanges,
          onChanged: provider.setEmployees,
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
          controller: _passwordController,
          onChanged: provider.setPassword,
          obscureText: true,
          style: _inputTextStyle,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '••••••••',
          ),
        ),
        const SizedBox(height: 18),
        _label('Confirmar contraseña'),
        const SizedBox(height: 7),
        TextField(
          controller: _confirmController,
          onChanged: provider.setConfirmPassword,
          obscureText: true,
          style: _inputTextStyle,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '••••••••',
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
                width: 20,
                height: 20,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: _termsTextColor,
                    ),
                    children: [
                      const TextSpan(text: 'Acepto los '),
                      TextSpan(
                        text: 'Términos',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' y la '),
                      TextSpan(
                        text: 'Política de privacidad',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
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

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _labelColor,
        ),
      );

  TextStyle get _inputTextStyle => GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSubtle),
      style: _inputTextStyle,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RegisterProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: AppColors.aprobadoBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 22),
          Text('Empresa registrada', style: AppTextStyles.tituloVista),
          const SizedBox(height: 8),
          Text(
            'Revisaremos tus datos y activaremos tu cuenta pronto.',
            style: AppTextStyles.cuerpo.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          OutlinedButton(
            onPressed: provider.resetForAnother,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: _logoutBorder, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
            child: Text(
              'Registrar otra',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
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
