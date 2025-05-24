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

  /// Cria um [UserModel] a partir de dados do Firestore (accounts collection).
  factory UserModel.fromFirestore(Map<String, dynamic> accountData) {
    final userData = accountData['user'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id: userData['id'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      token: '', // Token será obtido via Firebase Auth
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

  /// Converte para estrutura do Firestore (accounts collection).
  Map<String, dynamic> toFirestoreUser() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}