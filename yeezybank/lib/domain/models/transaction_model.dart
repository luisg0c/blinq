import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime timestamp;
  final List<String> participants;
  final String type;
  
  // Novos campos para robustez
  final String? transactionHash;      // Hash para verificação de integridade
  final String? referenceId;          // Identificação única da transação

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.participants,
    required this.type,
    this.transactionHash,
    this.referenceId,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      participants: List<String>.from(map['participants'] ?? []),
      type: map['type'] ?? 'unknown',
      transactionHash: map['transactionHash'],
      referenceId: map['referenceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'participants': participants,
      'type': type,
      'transactionHash': transactionHash,
      'referenceId': referenceId,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    double? amount,
    DateTime? timestamp,
    List<String>? participants,
    String? type,
    String? transactionHash,
    String? referenceId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      participants: participants ?? this.participants,
      type: type ?? this.type,
      transactionHash: transactionHash ?? this.transactionHash,
      referenceId: referenceId ?? this.referenceId,
    );
  }
  
  // Métodos de integridade
  
  /// Gera um hash para verificação de integridade da transação
  String generateHash() {
    final dataToHash = {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch.toString(),
      'type': type,
    };
    
    final jsonString = jsonEncode(dataToHash);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }
  
  /// Gera um ID de referência único
  String generateReferenceId() {
    final uniqueKey = '$senderId-$receiverId-$amount-${DateTime.now().millisecondsSinceEpoch}';
    final bytes = utf8.encode(uniqueKey);
    final shortHash = sha256.convert(bytes).toString().substring(0, 8);
    
    return 'TXN-${timestamp.millisecondsSinceEpoch}-$shortHash';
  }
  
  /// Verifica a integridade da transação
  bool verifyIntegrity() {
    if (transactionHash == null) return false;
    
    final calculatedHash = generateHash();
    return calculatedHash == transactionHash;
  }
}