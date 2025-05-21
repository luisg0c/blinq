/// Entidade que representa um usuário autenticado no sistema.
class User {
  final String id;
  final String name;
  final String email;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });
}
