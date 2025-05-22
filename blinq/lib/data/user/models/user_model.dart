import '../../../domain/entities/user.dart';

/// Modelo de dados do usuário usado na camada de dados.
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

  /// Constrói um [UserModel] a partir de um mapa (ex: Firestore).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
    );
  }

  /// Converte o [UserModel] para um mapa.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
