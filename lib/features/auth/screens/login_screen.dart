import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/greennode_logo.dart';
import '../providers/auth_provider.dart';

const _labelColor = Color(0xFF28392F);
const _rememberTextColor = Color(0xFF3E4F44);
const _logoutBorder = Color(0xFFBFE2CC);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _remember = false;
  bool _loggedIn = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().login(email: email, password: password);
      if (!mounted) return;
      setState(() { _loggedIn = true; _loading = false; });
      final rol = authProvider.rolActual;
      final router = GoRouter.of(context);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) router.go(rol == 'admin' ? '/admin/dashboard' : '/proyecto');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _logout() {
    setState(() {
      _loggedIn = false;
      _error = null;
      _emailController.clear();
      _passwordController.clear();
      _obscurePassword = true;
      _remember = false;
    });
    context.read<AuthProvider>().logout();
  }

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
              constraints: const BoxConstraints(maxWidth: 420),
              child: _loggedIn ? _buildSuccess() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: GreenNodeLogo(size: 28)),
        const SizedBox(height: 28),
        Text(
          'Bienvenido de nuevo',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.6,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para gestionar tu reforestación.',
          style: AppTextStyles.cuerpo,
        ),
        const SizedBox(height: 30),
        _label('Email'),
        const SizedBox(height: 7),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) { if (_error != null) setState(() => _error = null); },
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.ink,
          ),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'nombre@empresa.com',
          ),
        ),
        const SizedBox(height: 18),
        _label('Contraseña'),
        const SizedBox(height: 7),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (_) { if (_error != null) setState(() => _error = null); },
          onSubmitted: (_) => _login(),
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.ink,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '••••••••',
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    _obscurePassword ? 'Ver' : 'Ocultar',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Error de credenciales
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.rechazadoBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.rechazadoDot.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: AppColors.rechazadoDot),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.rechazadoText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 26),
        Row(
          children: [
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v),
                activeThumbColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Mantener sesión',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _rememberTextColor,
              ),
            ),
            const Spacer(),
            Text(
              '¿Olvidaste tu contraseña?',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(AppColors.primaryHover),
            ),
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Iniciar sesión',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.line, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'O',
                style: AppTextStyles.metadato.copyWith(color: AppColors.placeholder),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.line, height: 1)),
          ],
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _GoogleLogo(size: 18),
              const SizedBox(width: 10),
              Text(
                'Continuar con Google',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              '¿Tu empresa aún no está aquí? ',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/register'),
              child: Text(
                'Regístrala',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Credenciales de demo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Credenciales de demo',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.placeholder,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Admin: admin@greennode.co / Admin123!',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final esAdmin = authProvider.rolActual == 'admin';
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
          Text('¡Sesión iniciada!', style: AppTextStyles.tituloVista),
          const SizedBox(height: 8),
          Text(
            esAdmin
                ? 'Te llevamos al panel de administración.'
                : 'Te llevamos al panel de tu empresa.',
            style: AppTextStyles.cuerpo.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: _logoutBorder, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
            child: Text(
              'Cerrar sesión',
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

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _labelColor,
        ),
      );
}

/// Recreación simplificada del logo de Google (sin asset externo).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.62;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const fullCircle = 6.28318530718;
    const gap = 0.18;

    canvas.drawArc(rect, -0.55, fullCircle / 4 - gap, false, paint..color = const Color(0xFF4285F4));
    canvas.drawArc(rect, -0.55 + fullCircle / 4, fullCircle / 4 - gap, false, paint..color = const Color(0xFF34A853));
    canvas.drawArc(rect, -0.55 + fullCircle / 2, fullCircle / 4 - gap, false, paint..color = const Color(0xFFFBBC05));
    canvas.drawArc(rect, -0.55 + 3 * fullCircle / 4, fullCircle / 4 - gap, false, paint..color = const Color(0xFFEA4335));

    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 1, center.dy - strokeWidth / 2.6, radius - strokeWidth / 2 + 1, strokeWidth / 2.4),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
