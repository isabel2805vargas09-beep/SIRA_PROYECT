class Departamento {
  final String codigo;
  final String nombre;

  const Departamento({required this.codigo, required this.nombre});

  factory Departamento.fromMap(Map<String, dynamic> map) {
    return Departamento(
      codigo: (map['código'] ?? map['codigo'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
    );
  }
}
