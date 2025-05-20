class User {
  /// Identificador único do usuário.
  final String id;

  /// Nome completo do usuário.
  final String name;

  /// E-mail do usuário (utilizado para login).
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}
