import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Enum para os tipos de transação
enum TransactionType {
  deposit,
  transfer,
}

/// Enum para o status da transação
enum TransactionStatus {
  pending,
  completed,
  failed,
  canceled,
}

/// Modelo de transação financeira
class TransactionModel {
  final String id;
  final String senderId;
  final String? receiverId;
  final double amount;
  final String type;
  final String status;
  final List<String> participants;
  final String? description;
  final String? deviceId;
  final DateTime timestamp;
  final DateTime? confirmedAt;

  TransactionModel({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    required this.status,
    required this.participants,
    this.description,
    this.deviceId,
    required this.timestamp,
    this.confirmedAt,
  });

  /// Factory constructor para depósito
  factory TransactionModel.deposit({
    required String userId,
    required double amount,
    String? description,
    String? deviceId,
  }) {
    final now = DateTime.now();
    final id = const Uuid().v4();
    
    return TransactionModel(
      id: id,
      senderId: userId,
      receiverId: userId, // No depósito, o remetente é também o destinatário
      amount: amount,
      type: TransactionType.deposit.toString().split('.').last,
      status: TransactionStatus.pending.toString().split('.').last,
      participants: [userId], // Apenas o usuário está envolvido
      description: description,
      deviceId: deviceId,
      timestamp: now,
    );
  }

  /// Factory constructor para transferência
  factory TransactionModel.transfer({
    required String senderId,
    required String receiverId,
    required double amount,
    String? description,
    String? deviceId,
  }) {
    final now = DateTime.now();
    final id = const Uuid().v4();
    
    return TransactionModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      type: TransactionType.transfer.toString().split('.').last,
      status: TransactionStatus.pending.toString().split('.').last,
      participants: [senderId, receiverId], // Ambos os usuários estão envolvidos
      description: description,
      deviceId: deviceId,
      timestamp: now,
    );
  }

  /// Cria uma cópia do modelo com novos valores
  TransactionModel copyWith({
    String? id,
    String? status,
    DateTime? confirmedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: this.senderId,
      receiverId: this.receiverId,
      amount: this.amount,
      type: this.type,
      status: status ?? this.status,
      participants: this.participants,
      description: this.description,
      deviceId: this.deviceId,
      timestamp: this.timestamp,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  /// Converte o modelo para um Map para armazenamento no Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type,
      'status': status,
      'participants': participants,
      'description': description,
      'deviceId': deviceId,
      'timestamp': Timestamp.fromDate(timestamp),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
    };
  }

  /// Cria um modelo a partir de um Map do Firestore
  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'],
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      type: map['type'] ?? TransactionType.deposit.toString().split('.').last,
      status: map['status'] ?? TransactionStatus.pending.toString().split('.').last,
      participants: List<String>.from(map['participants'] ?? []),
      description: map['description'],
      deviceId: map['deviceId'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (map['confirmedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Cria um modelo a partir de um DocumentSnapshot do Firestore
  factory TransactionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TransactionModel.fromMap(data, doc.id);
  }
  
  /// Verifica se a transação está concluída
  bool get isCompleted => status == TransactionStatus.completed.toString().split('.').last;
  
  /// Verifica se a transação está pendente
  bool get isPending => status == TransactionStatus.pending.toString().split('.').last;
  
  /// Verifica se a transação falhou
  bool get isFailed => status == TransactionStatus.failed.toString().split('.').last;
  
  /// Verifica se a transação é um depósito
  bool get isDeposit => type == TransactionType.deposit.toString().split('.').last;
  
  /// Verifica se a transação é uma transferência
  bool get isTransfer => type == TransactionType.transfer.toString().split('.').last;
}