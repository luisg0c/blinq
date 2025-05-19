import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TransactionType { deposit, transfer, withdrawal }

enum TransactionStatus { pending, completed, failed, canceled }

class TransactionModel {
  final String id;
  final String senderId;
  final String? receiverId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? description;
  final String? deviceInfo;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    String? id,
    required this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.status = TransactionStatus.pending,
    DateTime? timestamp,
    this.description,
    this.deviceInfo,
    this.ipAddress,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now() {
    // Validações no construtor
    _validateTransaction();
  }

  // Métodos de fábrica para diferentes tipos de transação
  factory TransactionModel.deposit({
    required String userId,
    required double amount,
    String? description,
  }) {
    _validateAmount(amount);

    return TransactionModel(
      senderId: userId,
      receiverId: userId,
      amount: amount,
      type: TransactionType.deposit,
      description: description ?? 'Depósito em conta',
    );
  }

  factory TransactionModel.transfer({
    required String senderId,
    required String receiverId,
    required double amount,
    String? description,
  }) {
    _validateAmount(amount);

    if (senderId == receiverId) {
      throw ArgumentError('Remetente e destinatário não podem ser iguais');
    }

    return TransactionModel(
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      type: TransactionType.transfer,
      description: description ?? 'Transferência entre contas',
    );
  }

  factory TransactionModel.withdrawal({
    required String userId,
    required double amount,
    String? description,
  }) {
    _validateAmount(amount);

    return TransactionModel(
      senderId: userId,
      amount: amount,
      type: TransactionType.withdrawal,
      description: description ?? 'Saque em conta',
    );
  }

  // Validações internas
  void _validateTransaction() {
    _validateAmount(amount);
    _validateSender(senderId);
    if (receiverId != null) _validateReceiver(receiverId!);
  }

  // Validações estáticas
  static void _validateAmount(double amount) {
    if (amount <= 0) {
      throw ArgumentError('Valor da transação deve ser positivo');
    }

    if (amount > 10000.0) {
      throw ArgumentError('Valor máximo de transação excedido');
    }
  }

  static void _validateSender(String senderId) {
    if (senderId.isEmpty) {
      throw ArgumentError('ID do remetente inválido');
    }
  }

  static void _validateReceiver(String receiverId) {
    if (receiverId.isEmpty) {
      throw ArgumentError('ID do destinatário inválido');
    }
  }

  // Conversão para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }

  // Conversão do Firestore
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? const Uuid().v4(),
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'],
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.byName(map['type'] ?? 'deposit'),
      status: TransactionStatus.values.byName(map['status'] ?? 'pending'),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: map['description'],
      deviceInfo: map['deviceInfo'],
      ipAddress: map['ipAddress'],
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  // Método de cópia para atualizações
  TransactionModel copyWith({
    TransactionStatus? status,
    String? description,
  }) {
    return TransactionModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      type: type,
      status: status ?? this.status,
      timestamp: timestamp,
      description: description ?? this.description,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      metadata: metadata,
    );
  }

  // Métodos de verificação
  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isCanceled => status == TransactionStatus.canceled;

  // Métodos adicionais de segurança
  String generateTransactionHash() {
    // Método para gerar um hash único para a transação
    return DateTime.now().millisecondsSinceEpoch.toString() +
        id +
        amount.toString();
  }
}
