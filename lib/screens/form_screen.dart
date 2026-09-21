import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/aprendiz.dart';
import '../models/ciudad.dart';
import '../models/departamento.dart';
import '../repositories/aprendiz_repository.dart';
import '../repositories/catalog_repository.dart';
import 'login_screen.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final catalog = CatalogRepository();
  final repo = AprendizRepository();

  final id = TextEditingController();
  final n1 = TextEditingController();
  final n2 = TextEditingController();
  final a1 = TextEditingController();
  final a2 = TextEditingController();
  final cel = TextEditingController();
  final email = TextEditingController();

  List<Departamento> deps = [];
  List<Ciudad> cities = [];
  String? dep;
  String? city;
  String? gender;
  DateTime? birth;

  bool loading = false;
  bool loadingDeps = true;
  bool loadingCities = false;
  bool sidebarExpanded = true;
  String? status;
  bool statusError = false;

  @override
  void initState() {
    super.initState();
    loadDeps();
  }

  @override
  void dispose() {
    for (final c in [id, n1, n2, a1, a2, cel, email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> loadDeps() async {
    setState(() {
      loadingDeps = true;
      status = null;
      statusError = false;
    });

    try {
      final data = await catalog.getDepartamentos();
      if (!mounted) return;
      setState(() {
        deps = data;
        loadingDeps = false;
        status =
            '${data.length} departamentos disponibles · Supabase conectado';
        statusError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingDeps = false;
        status =
            'No fue posible cargar los departamentos: ${_friendlyError(e)}';
        statusError = true;
      });
    }
  }

  Future<void> loadCities(String value) async {
    setState(() {
      dep = value;
      city = null;
      cities = [];
      loadingCities = true;
    });

    try {
      final data = await catalog.getCiudades(value);
      if (!mounted) return;
      setState(() {
        cities = data;
        loadingCities = false;
        status =
            '${deps.length} departamentos disponibles · Supabase conectado';
        statusError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingCities = false;
        city = null;
        status = 'No fue posible cargar las ciudades: ${_friendlyError(e)}';
        statusError = true;
      });
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('PGRST204') && text.contains('ciudad')) {
      return 'la tabla aprendiz no coincide con las columnas configuradas';
    }
    if (text.contains('401')) {
      return 'Supabase rechazó la clave. Verifica la URL y la publishable key del proyecto';
    }
    return text
        .replaceFirst('PostgrestException(message: ', '')
        .replaceFirst(RegExp(r', code:.*$'), '');
  }

  Future<void> save() async {
    final documentText = id.text.trim();
    final phone = cel.text.trim();
    final mail = email.text.trim();

    if (documentText.isEmpty ||
        n1.text.trim().isEmpty ||
        a1.text.trim().isEmpty ||
        gender == null ||
        birth == null ||
        dep == null ||
        city == null ||
        phone.isEmpty ||
        mail.isEmpty) {
      _showMessage('Completa los campos obligatorios (*).', true);
      return;
    }

    final document = int.tryParse(documentText);
    if (document == null) {
      _showMessage('La identificación debe contener solamente números.', true);
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showMessage('El celular debe contener exactamente 10 dígitos.', true);
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(mail)) {
      _showMessage('Ingresa un correo electrónico válido.', true);
      return;
    }

    setState(() => loading = true);

    try {
      await repo.crear(
        Aprendiz(
          id: document,
          nombre1: n1.text.trim(),
          nombre2: n2.text.trim(),
          apellido1: a1.text.trim(),
          apellido2: a2.text.trim(),
          genero: gender!,
          fechaNacimiento: birth!,
          departamentoResidencia: dep!,
          ciudadResidencia: city!,
          celular: phone,
          email: mail,
        ),
      );

      if (!mounted) return;
      _clearFields();
      _showMessage('Aprendiz registrado correctamente en Supabase.', false);
    } catch (e) {
      if (!mounted) return;
      _showMessage(
          'No fue posible guardar el aprendiz: ${_friendlyError(e)}', true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _clearFields() {
    for (final c in [id, n1, n2, a1, a2, cel, email]) {
      c.clear();
    }
    setState(() {
      gender = null;
      birth = null;
      dep = null;
      city = null;
      cities = [];
    });
  }

  void _showMessage(String text, bool error) {
    if (!mounted) return;
    setState(() {
      status = error
          ? text
          : '${deps.length} departamentos disponibles · Supabase conectado';
      statusError = error;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor:
            error ? const Color(0xFFA62849) : const Color(0xFFC20D78),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final initial = birth ?? DateTime(now.year - 18);
    final value = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1940),
      lastDate: now,
      locale: const Locale('es'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC20D78),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF392334),
            ),
          ),
          child: child!,
        );
      },
    );
    if (value != null && mounted) setState(() => birth = value);
  }

  void logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD9ED),
      body: Stack(
        children: [
          Positioned(
              left: -170,
              top: -170,
              child: _circle(420, const Color(0xFFF7A9D4))),
          Positioned(
              right: -260, bottom: -270, child: _circle(520, Colors.white)),
          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 900;
                  final shellWidth = desktop
                      ? 1180.0
                      : (constraints.maxWidth - 20)
                          .clamp(300.0, 1180.0)
                          .toDouble();
                  final shellHeight = desktop
                      ? (constraints.maxHeight - 28)
                          .clamp(480.0, 760.0)
                          .toDouble()
                      : null;

                  final shell = Container(
                    width: shellWidth,
                    height: shellHeight,
                    margin: EdgeInsets.symmetric(
                      vertical: desktop ? 14 : 10,
                      horizontal: desktop ? 0 : 10,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x336D184E),
                          blurRadius: 80,
                          offset: Offset(0, 28),
                        ),
                      ],
                    ),
                    child: desktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRect(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  width: sidebarExpanded ? 340 : 0,
                                  child: sidebarExpanded
                                      ? _intro()
                                      : const SizedBox.shrink(),
                                ),
                              ),
                              Expanded(child: _form()),
                            ],
                          )
                        : Column(
                            children: [
                              _mobileIntro(),
                              Expanded(child: _form()),
                            ],
                          ),
                  );

                  return shell;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _intro() {
    return Container(
      width: 340,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA60663), Color(0xFFCE167F), Color(0xFFE54AA4)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(34, 42, 34, 34),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 76),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _logoMark(),
                    const SizedBox(height: 42),
                    _eyebrow(),
                    const SizedBox(height: 12),
                    _introTitle(),
                    const SizedBox(height: 17),
                    Text(
                      'Registra la información personal y de residencia de cada aprendiz de forma sencilla, organizada y conectada con Supabase.',
                      style: GoogleFonts.dmSans(
                          color: Colors.white.withOpacity(.92),
                          fontSize: 14,
                          height: 1.75),
                    ),
                    const SizedBox(height: 35),
                    _step('1', 'Información personal',
                        'Identificación, nombres y género', true),
                    const SizedBox(height: 20),
                    _step('2', 'Residencia', 'Departamento y ciudad', false),
                    const SizedBox(height: 20),
                    _step(
                        '3', 'Contacto', 'Celular y correo electrónico', false),
                    const Spacer(),
                    const SizedBox(height: 28),
                    _connectionCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mobileIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA60663), Color(0xFFCE167F), Color(0xFFE54AA4)],
        ),
      ),
      child: Row(
        children: [
          _logoMark(),
          const SizedBox(width: 18),
          Expanded(child: _introTitle(compact: true)),
        ],
      ),
    );
  }

  Widget _logoMark() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      alignment: Alignment.center,
      child: Text(
        'S',
        style: GoogleFonts.playfairDisplay(
          color: const Color(0xFFC20D78),
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _eyebrow() {
    return Text(
      'SISTEMA DE INFORMACIÓN',
      style: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w700),
    );
  }

  Widget _introTitle({bool compact = false}) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(),
          const SizedBox(height: 7),
          Text(
            'Registro de Aprendices',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 27, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Registro de\n',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w700,
                height: 1.08),
          ),
          TextSpan(
            text: 'Aprendices',
            style: GoogleFonts.playfairDisplay(
                color: const Color(0xFFFFD8ED),
                fontSize: 42,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.08),
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String title, String subtitle, bool active) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white.withOpacity(.55)),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.dmSans(
                color: active ? const Color(0xFFC20D78) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(.82), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _connectionCard() {
    final connected = !loadingDeps && !statusError && deps.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.23)),
      ),
      child: Row(
        children: [
          Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                  color: connected
                      ? const Color(0xFF72EFAD)
                      : const Color(0xFFFFC857),
                  shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    loadingDeps
                        ? 'Conectando base de datos'
                        : connected
                            ? 'Base de datos conectada'
                            : 'Revisar conexión',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Supabase · SIRA',
                    style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(.78), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _topbar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(48, 0, 48, 25),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _formHeader(),
                    if (status != null && statusError) _errorBanner(),
                    _personal(),
                    _residence(),
                    _contact(),
                    _actions(),
                    _footer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: sidebarExpanded ? 'Ocultar menú' : 'Mostrar menú',
            onPressed: () => setState(() => sidebarExpanded = !sidebarExpanded),
            icon: Icon(
                sidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
                color: const Color(0xFFC20D78),
                size: 22),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
                color: const Color(0xFFF9D7EB),
                borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF6C9E3), shape: BoxShape.circle),
                    child: Text('A',
                        style: GoogleFonts.dmSans(
                            color: const Color(0xFFC20D78),
                            fontSize: 11,
                            fontWeight: FontWeight.w800))),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Administrador',
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF392334),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  Text('Sesión activa',
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFFA18B98), fontSize: 9)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: logout,
            style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFF1F7),
                foregroundColor: const Color(0xFFA60663),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9))),
            child: Text('Cerrar sesión ↗',
                style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _formHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('NUEVO REGISTRO',
                  style: GoogleFonts.dmSans(
                      color: const Color(0xFFC20D78),
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text('Datos del aprendiz',
                  style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF392334),
                      fontSize: 30,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Completa los campos marcados con *.',
                  style: GoogleFonts.dmSans(
                      color: const Color(0xFF8C7182), fontSize: 13)),
            ]),
          ),
          const SizedBox(width: 20),
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFEDFAF3),
                borderRadius: BorderRadius.circular(30)),
            child: Text('● En línea',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFF16814B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF0F3),
          border: Border.all(color: const Color(0xFFF2C3CE)),
          borderRadius: BorderRadius.circular(11)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFA62849), size: 18),
          const SizedBox(width: 9),
          Expanded(
              child: Text(status!,
                  style: GoogleFonts.dmSans(
                      color: const Color(0xFFA62849),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.35))),
          IconButton(
              onPressed: () => setState(() {
                    status = null;
                    statusError = false;
                  }),
              icon: const Icon(Icons.close, size: 16, color: Color(0xFFA62849)),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget _personal() {
    return _section(
      _sectionHeader(
          '01', 'Información personal', 'Identificación y datos básicos.'),
      LayoutBuilder(builder: (context, c) {
        final two = c.maxWidth >= 620;
        final w = two ? (c.maxWidth - 17) / 2 : c.maxWidth;
        return Wrap(
          spacing: 17,
          runSpacing: 17,
          children: [
            SizedBox(
                width: w,
                child: _text(id, 'Identificación (ID)',
                    placeholder: 'Ej. 1108151107',
                    prefix: '#',
                    numeric: true,
                    max: 20,
                    hint: 'Solo números.')),
            SizedBox(width: w, child: _gender()),
            SizedBox(
                width: w,
                child: _text(n1, 'Primer nombre',
                    placeholder: 'Ej. Felipe', max: 20)),
            SizedBox(
                width: w,
                child: _text(n2, 'Segundo nombre',
                    placeholder: 'Ej. Andrés', required: false, max: 20)),
            SizedBox(
                width: w,
                child: _text(a1, 'Primer apellido',
                    placeholder: 'Ej. Torres', max: 20)),
            SizedBox(
                width: w,
                child: _text(a2, 'Segundo apellido',
                    placeholder: 'Ej. Rivera', required: false, max: 20)),
            SizedBox(width: w, child: _date()),
          ],
        );
      }),
    );
  }

  Widget _residence() {
    return _section(
      _sectionHeader('02', 'Lugar de residencia',
          'Selecciona el departamento para cargar sus ciudades.'),
      LayoutBuilder(builder: (context, c) {
        final two = c.maxWidth >= 620;
        final w = two ? (c.maxWidth - 17) / 2 : c.maxWidth;
        return Wrap(spacing: 17, runSpacing: 17, children: [
          SizedBox(width: w, child: _department()),
          SizedBox(width: w, child: _city()),
        ]);
      }),
    );
  }

  Widget _contact() {
    return _section(
      _sectionHeader('03', 'Datos de contacto',
          'Información para comunicarse con el aprendiz.'),
      LayoutBuilder(builder: (context, c) {
        final two = c.maxWidth >= 620;
        final w = two ? (c.maxWidth - 17) / 2 : c.maxWidth;
        return Wrap(spacing: 17, runSpacing: 17, children: [
          SizedBox(
              width: w,
              child: _text(cel, 'Número de celular',
                  placeholder: 'Ej. 3001234567',
                  numeric: true,
                  max: 10,
                  hint: 'Debe contener 10 dígitos.')),
          SizedBox(
              width: w,
              child: _text(email, 'Correo electrónico',
                  placeholder: 'aprendiz@correo.com', max: 50)),
        ]);
      }),
    );
  }

  Widget _section(Widget header, Widget body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF0E2EA)))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [header, const SizedBox(height: 18), body]),
    );
  }

  Widget _sectionHeader(String number, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: 37,
            height: 37,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFF9D7EB),
                borderRadius: BorderRadius.circular(12)),
            child: Text(number,
                style: GoogleFonts.dmSans(
                    color: const Color(0xFFC20D78),
                    fontSize: 11,
                    fontWeight: FontWeight.w800))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.dmSans(
                  color: const Color(0xFF392334),
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: GoogleFonts.dmSans(
                  color: const Color(0xFF8C7182), fontSize: 11)),
        ])),
      ],
    );
  }

  Widget _text(TextEditingController controller, String label,
      {String? placeholder,
      String? hint,
      bool required = true,
      bool numeric = false,
      int? max,
      String? prefix}) {
    return _shell(
      label,
      required: required,
      hint: hint,
      child: TextField(
        controller: controller,
        maxLength: max,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        inputFormatters:
            numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: GoogleFonts.dmSans(color: const Color(0xFF392334), fontSize: 13),
        decoration: _dec(placeholder, prefix: prefix),
      ),
    );
  }

  Widget _gender() {
    return _shell(
      'Género',
      child: DropdownButtonFormField<String>(
        value: gender,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'F', child: Text('Femenino (F)')),
          DropdownMenuItem(value: 'M', child: Text('Masculino (M)')),
        ],
        onChanged: (v) => setState(() => gender = v),
        decoration: _dec('Seleccionar género'),
      ),
    );
  }

  Widget _date() {
    final label = birth == null
        ? 'dd/mm/aaaa'
        : '${birth!.day.toString().padLeft(2, '0')}/${birth!.month.toString().padLeft(2, '0')}/${birth!.year}';
    return _shell(
      'Fecha de nacimiento',
      child: InkWell(
        onTap: pickDate,
        borderRadius: BorderRadius.circular(11),
        child: InputDecorator(
          decoration: _dec(null).copyWith(
              suffixIcon: const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFF392334))),
          child: Text(label,
              style: GoogleFonts.dmSans(
                  color: birth == null
                      ? const Color(0xFFB19DAA)
                      : const Color(0xFF392334),
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _department() {
    return _shell(
      'Departamento',
      hint: loadingDeps
          ? 'Conectando con Supabase...'
          : '${deps.length} departamentos disponibles · Supabase conectado',
      child: DropdownButtonFormField<String>(
        value: dep,
        isExpanded: true,
        hint: Text(
            loadingDeps
                ? 'Cargando departamentos...'
                : 'Selecciona un departamento',
            style: GoogleFonts.dmSans(
                color: const Color(0xFF8C7182), fontSize: 13)),
        items: deps
            .map((d) => DropdownMenuItem<String>(
                value: d.codigo,
                child: Text('${d.nombre} (${d.codigo})',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 13))))
            .toList(),
        onChanged: loadingDeps
            ? null
            : (v) {
                if (v != null) loadCities(v);
              },
        decoration: _dec(null),
      ),
    );
  }

  Widget _city() {
    return _shell(
      'Ciudad / municipio',
      hint: 'Las ciudades se filtran automáticamente.',
      child: DropdownButtonFormField<String>(
        value: city,
        isExpanded: true,
        hint: Text(
            loadingCities
                ? 'Cargando ciudades...'
                : dep == null
                    ? 'Selecciona primero un departamento'
                    : 'Selecciona una ciudad',
            style: GoogleFonts.dmSans(
                color: const Color(0xFFB19DAA), fontSize: 13)),
        items: cities
            .map((c) => DropdownMenuItem<String>(
                value: c.codigo,
                child: Text('${c.nombre} (${c.codigo})',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 13))))
            .toList(),
        onChanged: loadingCities || dep == null
            ? null
            : (v) => setState(() => city = v),
        decoration: _dec(null),
      ),
    );
  }

  Widget _shell(String label,
      {required Widget child, String? hint, bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.dmSans(
                color: const Color(0xFF593E4E),
                fontSize: 12,
                fontWeight: FontWeight.w700),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                    text: ' *', style: TextStyle(color: Color(0xFFC20D78))),
            ],
          ),
        ),
        const SizedBox(height: 7),
        child,
        if (hint != null) ...[
          const SizedBox(height: 5),
          Text(hint,
              style: GoogleFonts.dmSans(
                  color: const Color(0xFFA18B98), fontSize: 10)),
        ],
      ],
    );
  }

  InputDecoration _dec(String? hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(
        color: const Color(0xFFB19DAA),
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFFFF8FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      prefixIcon: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(
                left: 13,
                right: 8,
              ),
              child: Text(
                prefix,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFC20D78),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFEAD9E4),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFEAD9E4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFC20D78),
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFEAD9E4),
        ),
      ),
      counterText: '',
    );
  }

  Widget _actions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 22),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF0E2EA)))),
      child: LayoutBuilder(builder: (context, c) {
        final compact = c.maxWidth < 650;
        final buttons = Row(mainAxisSize: MainAxisSize.min, children: [
          TextButton(
            onPressed: loading ? null : _clearFields,
            style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF6EAF1),
                foregroundColor: const Color(0xFF7B4965),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11))),
            child: Text('Limpiar formulario',
                style: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: loading ? null : save,
            style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFC20D78),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (loading)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
              if (loading) const SizedBox(width: 8),
              Text(loading ? 'Guardando...' : 'Registrar aprendiz',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]);

        return compact
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(
                    text: TextSpan(
                        style: GoogleFonts.dmSans(
                            color: const Color(0xFF8C7182), fontSize: 10),
                        children: const [
                      TextSpan(
                          text: '*',
                          style: TextStyle(
                              color: Color(0xFFC20D78),
                              fontWeight: FontWeight.w700)),
                      TextSpan(text: ' Campos obligatorios')
                    ])),
                const SizedBox(height: 15),
                Align(alignment: Alignment.centerRight, child: buttons),
              ])
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    RichText(
                        text: TextSpan(
                            style: GoogleFonts.dmSans(
                                color: const Color(0xFF8C7182), fontSize: 10),
                            children: const [
                          TextSpan(
                              text: '*',
                              style: TextStyle(
                                  color: Color(0xFFC20D78),
                                  fontWeight: FontWeight.w700)),
                          TextSpan(text: ' Campos obligatorios')
                        ])),
                    buttons,
                  ]);
      }),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.only(top: 23),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('SIRA Web',
            style: GoogleFonts.dmSans(
                color: const Color(0xFFC20D78),
                fontSize: 10,
                fontWeight: FontWeight.w800)),
        Text('  •  ',
            style: GoogleFonts.dmSans(
                color: const Color(0xFFAA96A3), fontSize: 10)),
        Text('Registro de Aprendices',
            style: GoogleFonts.dmSans(
                color: const Color(0xFFAA96A3), fontSize: 10)),
        Text('  •  ',
            style: GoogleFonts.dmSans(
                color: const Color(0xFFAA96A3), fontSize: 10)),
        Text('Supabase',
            style: GoogleFonts.dmSans(
                color: const Color(0xFFAA96A3), fontSize: 10)),
      ]),
    );
  }
}
