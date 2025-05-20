import '/../domain/entities/user.dart';

/// Modelo de dados que representa o usuário vindo da camada de dados.
class UserModel extends User {
  /// Token JWT obtido no login/registro.
  final String token;

  const UserModel({
    required String id,
    required String name,
    required String email,
    required this.token,
  }) : super(id: id, name: name, email: email);

  /// Constrói um [UserModel] a partir de um JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }

  /// Converte o modelo para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }

  /// Cria uma cópia do modelo, permitindo sobrescrever campos.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }
}
