import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

class TransactionService {
  final TransactionRepository _transactionRepository;
  final UserRepository _userRepository;
  final AuthService _authService;

  TransactionService({
    TransactionRepository? transactionRepository,
    UserRepository? userRepository,
    AuthService? authService,
  })  : _transactionRepository =
            transactionRepository ?? TransactionRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _authService = authService ?? AuthService();

  // Depósito com validações
  Future<TransactionModel?> deposit({
    required double amount,
    String? description,
  }) async {
    try {
      // Validar usuário autenticado
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Validar valor do depósito
      _validateDepositAmount(amount);

      // Criar transação de depósito
      final transaction = TransactionModel.deposit(
        userId: currentUser.id,
        amount: amount,
        description: description ?? 'Depósito em conta',
      );

      // Processar transação
      final savedTransaction =
          await _transactionRepository.createTransaction(transaction);

      if (savedTransaction != null) {
        // Atualizar saldo
        await _userRepository.updateBalance(currentUser.id, amount);
        return savedTransaction;
      }

      throw Exception('Falha ao processar depósito');
    } catch (e) {
      print('Erro no depósito: $e');
      rethrow;
    }
  }

  // Transferência com validações
  Future<TransactionModel?> transfer({
    required String receiverEmail,
    required double amount,
    String? description,
  }) async {
    try {
      // Validar usuário autenticado
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Buscar usuário destinatário
      final receiverUser = await _userRepository.getUserByEmail(receiverEmail);
      if (receiverUser == null) {
        throw Exception('Destinatário não encontrado');
      }

      // Validações de transferência
      _validateTransferAmount(amount);
      _validateTransferRecipient(currentUser, receiverUser);

      // Criar transação de transferência
      final transaction = TransactionModel.transfer(
        senderId: currentUser.id,
        receiverId: receiverUser.id,
        amount: amount,
        description: description ?? 'Transferência entre contas',
      );

      // Processar transação
      final savedTransaction =
          await _transactionRepository.createTransaction(transaction);

      if (savedTransaction != null) {
        // Atualizar saldos
        await _userRepository.updateBalance(currentUser.id, -amount);
        await _userRepository.updateBalance(receiverUser.id, amount);
        return savedTransaction;
      }

      throw Exception('Falha ao processar transferência');
    } catch (e) {
      print('Erro na transferência: $e');
      rethrow;
    }
  }

  // Validações de depósito
  void _validateDepositAmount(double amount) {
    if (amount <= 0) {
      throw Exception('Valor de depósito inválido');
    }
    if (amount > 10000.0) {
      throw Exception('Valor máximo de depósito excedido');
    }
  }

  // Validações de transferência
  void _validateTransferAmount(double amount) {
    if (amount <= 0) {
      throw Exception('Valor de transferência inválido');
    }
    if (amount > 5000.0) {
      throw Exception('Valor máximo de transferência excedido');
    }
  }

  // Validar destinatário da transferência
  void _validateTransferRecipient(UserModel sender, UserModel receiver) {
    if (sender.id == receiver.id) {
      throw Exception('Não é possível transferir para a própria conta');
    }
    if (!receiver.canTransact) {
      throw Exception('Conta do destinatário não está ativa');
    }
  }

  // Buscar transações do usuário
  Future<List<TransactionModel>> getUserTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    int limit = 20,
  }) async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    return await _transactionRepository.getUserTransactions(
      currentUser.id,
      startDate: startDate,
      endDate: endDate,
      type: type,
      limit: limit,
    );
  }

  // Obter total de depósitos
  Future<double> getTotalDeposits({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    return await _transactionRepository.getTotalTransactionsByType(
      currentUser.id,
      TransactionType.deposit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Obter total de transferências
  Future<double> getTotalTransfers({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    return await _transactionRepository.getTotalTransactionsByType(
      currentUser.id,
      TransactionType.transfer,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Gerar comprovante em PDF
  Future<File> generateTransactionReceipt(TransactionModel transaction) async {
    final pdf = pw.Document();
    final sender = await _userRepository.getUserById(transaction.senderId);
    final receiver = transaction.receiverId != null
        ? await _userRepository.getUserById(transaction.receiverId!)
        : null;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Comprovante de Transação',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('ID: ${transaction.id}'),
          pw.Text(
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp)}'),
          pw.Text('Tipo: ${transaction.type.name.toUpperCase()}'),
          pw.Text('Valor: R\$ ${transaction.amount.toStringAsFixed(2)}'),
          pw.SizedBox(height: 20),
          pw.Text('Remetente: ${sender?.name ?? 'Não identificado'}'),
          if (receiver != null) pw.Text('Destinatário: ${receiver.name}'),
          pw.Text('Descrição: ${transaction.description ?? 'Sem descrição'}'),
        ]),
      ),
    );

    // Salvar PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/comprovante_${transaction.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Compartilhar comprovante
  Future<void> shareTransactionReceipt(TransactionModel transaction) async {
    try {
      final file = await generateTransactionReceipt(transaction);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Comprovante de Transação');
    } catch (e) {
      print('Erro ao compartilhar comprovante: $e');
      rethrow;
    }
  }

  // Resumo financeiro
  Future<Map<String, double>> getFinancialSummary() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    final deposits = await getTotalDeposits();
    final transfers = await getTotalTransfers();

    return {
      'deposits': deposits,
      'transfers': transfers,
      'total': deposits - transfers
    };
  }
}
