class Aprendiz {
  final int id;
  final String nombre1;
  final String? nombre2;
  final String apellido1;
  final String? apellido2;
  final String genero;
  final DateTime fechaNacimiento;
  final String departamentoResidencia;
  final String ciudadResidencia;
  final String celular;
  final String email;

  const Aprendiz({
    required this.id,
    required this.nombre1,
    this.nombre2,
    required this.apellido1,
    this.apellido2,
    required this.genero,
    required this.fechaNacimiento,
    required this.departamentoResidencia,
    required this.ciudadResidencia,
    required this.celular,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre1': nombre1,
      'nombre2': nombre2?.trim().isEmpty == true ? null : nombre2?.trim(),
      'apellido1': apellido1,
      'apellido2': apellido2?.trim().isEmpty == true ? null : apellido2?.trim(),
      'genero': genero,
      'fecha_nacimiento': _dateOnly(fechaNacimiento),
      'departamento_residencia': departamentoResidencia,
      'ciudad_residencia': ciudadResidencia,
      'celular': celular,
      'email': email,
    };
  }

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
