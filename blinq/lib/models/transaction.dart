import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { deposit, transfer }
<<<<<<< Updated upstream

enum TransactionStatus { pending, completed, failed, canceled }

class TransactionModel {
=======
enum TransactionStatus { pending, completed, failed, canceled }

class Transaction {
>>>>>>> Stashed changes
  final String id;
  final String senderId;
  final String? receiverId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final List<String> participants;
  final String? description;
  final DateTime timestamp;

<<<<<<< Updated upstream
  TransactionModel({
=======
  Transaction({
>>>>>>> Stashed changes
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.status = TransactionStatus.pending,
    List<String>? participants,
    this.description,
    DateTime? timestamp,
<<<<<<< Updated upstream
  })  : this.participants =
            participants ?? [senderId, if (receiverId != null) receiverId],
        this.timestamp = timestamp ?? DateTime.now();
=======
  }) : 
    this.participants = participants ?? [senderId, if (receiverId != null) receiverId],
    this.timestamp = timestamp ?? DateTime.now();
>>>>>>> Stashed changes

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'participants': participants,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

<<<<<<< Updated upstream
  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
=======
  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
>>>>>>> Stashed changes
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'],
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      type: _parseTransactionType(map['type']),
      status: _parseTransactionStatus(map['status']),
      participants: List<String>.from(map['participants'] ?? []),
      description: map['description'],
<<<<<<< Updated upstream
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
=======
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
>>>>>>> Stashed changes
    );
  }

  static TransactionType _parseTransactionType(String? value) {
    if (value == 'transfer') return TransactionType.transfer;
    return TransactionType.deposit;
  }

  static TransactionStatus _parseTransactionStatus(String? value) {
    if (value == 'completed') return TransactionStatus.completed;
    if (value == 'failed') return TransactionStatus.failed;
    if (value == 'canceled') return TransactionStatus.canceled;
    return TransactionStatus.pending;
  }

  bool get isDeposit => type == TransactionType.deposit;
  bool get isTransfer => type == TransactionType.transfer;
  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
<<<<<<< Updated upstream
}
=======
}
>>>>>>> Stashed changes
