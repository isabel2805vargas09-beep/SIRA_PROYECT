class Ciudad {
  final String departamento;
  final String codigo;
  final String nombre;

  const Ciudad({
    required this.departamento,
    required this.codigo,
    required this.nombre,
  });

  factory Ciudad.fromMap(Map<String, dynamic> map) {
    return Ciudad(
      departamento: (map['departamento'] ?? '').toString(),
      codigo: (map['código'] ?? map['codigo'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
    );
  }
}
