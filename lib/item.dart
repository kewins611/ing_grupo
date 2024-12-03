class Item {
  final int? id;
  final String name;
  final String surname; // Apellido
  final String matricula; // Matrícula
  final String description; // Descripción

  Item({
    this.id,
    required this.name,
    required this.surname,
    required this.matricula,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'matricula': matricula,
      'description': description,
    };
  }

  static Item fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      surname: map['surname'],
      matricula: map['matricula'],
      description: map['description'],
    );
  }
}
