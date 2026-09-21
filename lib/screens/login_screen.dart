import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'form_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  String? errorMessage;

  static const adminUser = 'Administrador';
  static const adminPassword = 'SENA_TOL3409633';

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final user = userController.text.trim();
    final password = passwordController.text;

    if (user == adminUser && password == adminPassword) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const FormScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
      return;
    }

    setState(() {
      errorMessage = 'Usuario o contraseña incorrectos.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFE5F3),
                  Color(0xFFF8B1D9),
                  Color(0xFFFFF7FB),
                ],
              ),
            ),
          ),
          Positioned(
            left: -220,
            top: -180,
            child: _circle(430, const Color(0xFFF4A1D0)),
          ),
          Positioned(
            right: -260,
            bottom: -250,
            child: _circle(500, Colors.white),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Container(
                width: 430,
                padding: const EdgeInsets.fromLTRB(42, 38, 42, 38),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.96),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(.8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x336D184E),
                      blurRadius: 80,
                      offset: Offset(0, 28),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFA60663), Color(0xFFE54AA4)],
                        ),
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3DC20D78),
                            blurRadius: 28,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'S',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'SIRA WEB',
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFA60663),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistema de Información para el Registro de Aprendices',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF967C8B),
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 23),
                    Container(height: 1, color: const Color(0xFFF0DFE9)),
                    const SizedBox(height: 25),
                    _LoginField(
                      label: 'Usuario',
                      controller: userController,
                      hint: 'Administrador',
                      prefix: '◉',
                      onChanged: (_) => _clearError(),
                    ),
                    const SizedBox(height: 17),
                    _LoginField(
                      label: 'Contraseña',
                      controller: passwordController,
                      hint: 'Ingresa tu contraseña',
                      prefix: '◆',
                      obscureText: obscurePassword,
                      onChanged: (_) => _clearError(),
                      suffix: IconButton(
                        tooltip: obscurePassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () => setState(
                          () => obscurePassword = !obscurePassword,
                        ),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Color(0xFF9D8190),
                        ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          border: Border.all(color: const Color(0xFFF2C3CE)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          errorMessage!,
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFFA62849),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 17),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFC20D78),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Iniciar sesión  →',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF27B66D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Acceso seguro · SIRA Web',
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF7D6875),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'Panel administrativo para gestión de aprendices',
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFB19DAA),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearError() {
    if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _LoginField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String prefix;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const _LoginField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.prefix,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: const Color(0xFF583D4E),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAD9E4)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 13),
              Text(
                prefix,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFC20D78),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF392334),
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: GoogleFonts.dmSans(
                      color: const Color(0xFFB19DAA),
                      fontSize: 13,
                    ),
                    isCollapsed: true,
                  ),
                ),
              ),
              if (suffix != null) suffix! else const SizedBox(width: 13),
            ],
          ),
        ),
      ],
    );
  }
}
