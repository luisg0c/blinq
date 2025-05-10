import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TransactionStatus { 
  pending, 
  confirmed, 
  completed, 
  failed 
}

enum TransactionType { 
  deposit, 
  transfer 
}

class TransactionModel {
  final String id;
  final String senderId;
  final String? receiverId;
  final double amount;
  final DateTime timestamp;
  final TransactionType type;
  final TransactionStatus status;
  final List<String> participants;
  final String? description;
  final String? transactionToken;
  final String? confirmationCode;

  TransactionModel({
    String? id,
    required this.senderId,
    this.receiverId,
    required this.amount,
    DateTime? timestamp,
    required this.type,
    this.status = TransactionStatus.pending,
    List<String>? participants,
    this.description,
    this.transactionToken,
    this.confirmationCode,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now(),
    participants = participants ?? [senderId, if(receiverId != null) receiverId];

  // Conversão para/de Map
  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      amount: map['amount'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: TransactionType.values.byName(map['type']),
      status: TransactionStatus.values.byName(map['status']),
      participants: List<String>.from(map['participants']),
      description: map['description'],
      transactionToken: map['transactionToken'],
      confirmationCode: map['confirmationCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'status': status.name,
      'participants': participants,
      'description': description,
      'transactionToken': transactionToken,
      'confirmationCode': confirmationCode,
    };
  }
}