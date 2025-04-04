import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/services/transaction_service.dart';

class TransactionConfirmationDialog extends StatefulWidget {
  final TransactionModel transaction;
  final String receiverEmail;

  const TransactionConfirmationDialog({
    Key? key,
    required this.transaction,
    required this.receiverEmail,
  }) : super(key: key);

  @override
  State<TransactionConfirmationDialog> createState() => _TransactionConfirmationDialogState();
}

class _TransactionConfirmationDialogState extends State<TransactionConfirmationDialog> {
  final TransactionService _transactionService = Get.find<TransactionService>();
  final TextEditingController _codeController = TextEditingController();
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Transferência'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para sua segurança, confirme os detalhes da transferência:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Destinatário:', widget.receiverEmail),
            _buildInfoRow('Valor:', 'R\$ ${widget.transaction.amount.toStringAsFixed(2)}'),
            _buildInfoRow('Data:', _formatDate(widget.transaction.timestamp)),
            
            const SizedBox(height: 24),
            const Text(
              'Digite o código de confirmação:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'O código de 6 dígitos para esta transação é:',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            
            // Display do código (simulando que foi enviado por outro canal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                widget.transaction.confirmationCode ?? 'Erro: código não gerado',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campo de entrada do código
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Código de confirmação',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                letterSpacing: 8,
                fontSize: 20,
              ),
            ),
            
            const SizedBox(height: 8),
            Text(
              'Em um aplicativo real, este código seria enviado por SMS ou notificação push.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConfirming ? null : () => Get.back(result: false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isConfirming ? null : _confirmTransaction,
          child: _isConfirming
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmTransaction() async {
    final code = _codeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Insira o código de confirmação';
      });
      return;
    }
    
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'O código deve ter 6 dígitos';
      });
      return;
    }
    
    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });
    
    try {
      await _transactionService.confirmTransaction(
        widget.transaction.id,
        code,
      );
      
      Get.back(result: true);
      Get.snackbar(
        'Sucesso', 
        'Transferência confirmada com sucesso!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      setState(() {
        _isConfirming = false;
        _errorMessage = e.toString();
      });
    }
  }
}