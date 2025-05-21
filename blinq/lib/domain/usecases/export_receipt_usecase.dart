import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../entities/transaction.dart';
import '../../core/constants/app_keys.dart';

/// Caso de uso para exportar um comprovante de transação como PDF.
class ExportReceiptUseCase {
  Future<File> execute(Transaction transaction) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Comprovante de Transação', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Tipo: ${transaction.type}'),
                pw.Text('Descrição: ${transaction.description}'),
                pw.Text('Valor: R\$ ${transaction.amount.toStringAsFixed(2)}'),
                pw.Text('Data: ${transaction.date}'),
                if (transaction.counterparty != null)
                  pw.Text('Destinatário: ${transaction.counterparty}'),
                pw.Text('ID: ${transaction.id}'),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${AppKeys.receiptPdfFileName}');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
