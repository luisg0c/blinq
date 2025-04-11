import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// Definição do enum para status de transação
enum TransactionStatus {
  pending, // Aguardando confirmação
  confirmed, // Confirmada pelo usuário
  completed, // Processada completamente
  failed, // Falhou
}

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime timestamp;
  final List<String> participants;
  final String type;

  // Campos para segurança e integridade
  final String? transactionHash;
  final String? referenceId;
  final String? transactionToken;
  final TransactionStatus? status;
  final String? deviceId;
  final String? confirmationCode;
  final DateTime? confirmedAt;

  // Novo campo: descrição
  final String? description;

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
    this.transactionToken,
    this.status,
    this.deviceId,
    this.confirmationCode,
    this.confirmedAt,
    this.description,
  });

  // Construtor para depósitos
  factory TransactionModel.deposit({
    required String userId,
    required double amount,
    String? description,
    String? deviceId,
  }) {
    final now = DateTime.now();
    final txn = TransactionModel(
      id: '',
      senderId: userId,
      receiverId: userId,
      amount: amount,
      timestamp: now,
      participants: [userId],
      type: 'deposit',
      status: TransactionStatus.completed,
      deviceId: deviceId,
      description: description,
    );

    // Gerar token único
    final token = txn.generateToken();

    return txn.copyWith(
      transactionToken: token,
      transactionHash: txn.generateHash(),
      referenceId: txn.generateReferenceId(),
    );
  }

  // Construtor para transferências
  factory TransactionModel.transfer({
    required String senderId,
    required String receiverId,
    required double amount,
    String? description,
    String? deviceId,
  }) {
    final now = DateTime.now();
    final txn = TransactionModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      timestamp: now,
      participants: [senderId, receiverId],
      type: 'transfer',
      status: TransactionStatus.pending,
      deviceId: deviceId,
      description: description,
    );

    // Gerar token e código de confirmação
    final token = txn.generateToken();
    final confirmationCode = txn.generateConfirmationCode();

    return txn.copyWith(
      transactionToken: token,
      confirmationCode: confirmationCode,
      transactionHash: txn.generateHash(),
      referenceId: txn.generateReferenceId(),
    );
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
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
      transactionToken: map['transactionToken'],
      status: _statusFromString(map['status']),
      deviceId: map['deviceId'],
      confirmationCode: map['confirmationCode'],
      confirmedAt:
          map['confirmedAt'] != null
              ? (map['confirmedAt'] as Timestamp).toDate()
              : null,
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'participants': participants,
      'type': type,
      'transactionHash': transactionHash,
      'referenceId': referenceId,
      'transactionToken': transactionToken,
      'deviceId': deviceId,
      'confirmationCode': confirmationCode,
      'description': description,
    };

    if (status != null) {
      data['status'] = status.toString().split('.').last;
    }

    if (confirmedAt != null) {
      data['confirmedAt'] = Timestamp.fromDate(confirmedAt!);
    }

    return data;
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
    String? transactionToken,
    TransactionStatus? status,
    String? deviceId,
    String? confirmationCode,
    DateTime? confirmedAt,
    String? description,
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
      transactionToken: transactionToken ?? this.transactionToken,
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      description: description ?? this.description,
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
    final uniqueKey =
        '$senderId-$receiverId-$amount-${DateTime.now().millisecondsSinceEpoch}';
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

  /// Gera um token único para a transação (estilo Nubank)
  String generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final uniqueKey =
        '$senderId-$receiverId-$amount-$timestamp-${_randomString(8)}';
    final bytes = utf8.encode(uniqueKey);
    return sha256.convert(bytes).toString();
  }

  /// Gera um código de confirmação de 6 dígitos (estilo Nubank)
  String generateConfirmationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // 6 dígitos
  }

  /// Verifica validade do código de confirmação
  bool validateConfirmationCode(String code) {
    return confirmationCode == code;
  }

  /// Gera string aleatória para reforçar a unicidade
  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Método auxiliar para converter string para enum
  static TransactionStatus? _statusFromString(String? status) {
    if (status == null) return null;

    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'confirmed':
        return TransactionStatus.confirmed;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return null;
    }
  }

  // Retorna uma versão amigável do status para display
  String get statusDisplay {
    if (status == null) return 'Desconhecido';

    switch (status!) {
      case TransactionStatus.pending:
        return 'Pendente';
      case TransactionStatus.confirmed:
        return 'Confirmada';
      case TransactionStatus.completed:
        return 'Concluída';
      case TransactionStatus.failed:
        return 'Falha';
    }
  }

  // Retorna se a transação foi concluída com sucesso
  bool get isCompleted => status == TransactionStatus.completed;

  // Retorna se a transação está pendente
  bool get isPending => status == TransactionStatus.pending;

  // Retorna se a transação falhou
  bool get isFailed => status == TransactionStatus.failed;
}
