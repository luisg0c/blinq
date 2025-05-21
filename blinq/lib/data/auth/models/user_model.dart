import '../../../domain/entities/user.dart';

/// Modelo de usuário usado na camada de dados.
/// Estende a entidade [User] da camada de domínio.
class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    required String token,
  }) : super(
          id: id,
          name: name,
          email: email,
          token: token,
        );

  /// Cria um [UserModel] a partir de um Map (ex: Firestore).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
    );
  }

  /// Converte para Map (útil para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
