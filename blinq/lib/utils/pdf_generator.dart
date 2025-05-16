import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'formatters.dart';

class PdfGenerator {
  // Evitar instanciação
  PdfGenerator._();

  /// Gera um comprovante de transação em PDF
  static Future<File> generateTransactionReceipt({
    required Transaction transaction,
    String? counterpartyName,
  }) async {
    final pdf = pw.Document();

    // Obter fonte
    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    // Criar conteúdo do PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BLINQ',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Comprovante de Transação',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      Formatters.formatDateTime(DateTime.now()),
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Detalhes da Transação
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.grey300,
                      width: 1,
                    ),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Tipo
                      _buildPdfDetailRow(
                        ttf,
                        'Tipo de Transação:',
                        transaction.isDeposit ? 'Depósito' : 'Transferência',
                      ),

                      pw.SizedBox(height: 12),

                      // Status
                      _buildPdfDetailRow(
                        ttf,
                        'Status:',
                        transaction.isCompleted
                            ? 'Concluída'
                            : transaction.isPending
                                ? 'Pendente'
                                : 'Falhou',
                      ),

                      pw.SizedBox(height: 12),

                      // Valor
                      _buildPdfDetailRow(
                        ttf,
                        'Valor:',
                        Formatters.formatCurrency(transaction.amount),
                        bold: true,
                      ),

                      pw.SizedBox(height: 12),

                      // Data
                      _buildPdfDetailRow(
                        ttf,
                        'Data:',
                        Formatters.formatDateTime(transaction.timestamp),
                      ),

                      if (transaction.isTransfer &&
                          counterpartyName != null) ...[
                        pw.SizedBox(height: 12),
                        _buildPdfDetailRow(
                          ttf,
                          'Contraparte:',
                          counterpartyName,
                        ),
                      ],

                      if (transaction.description != null &&
                          transaction.description!.isNotEmpty) ...[
                        pw.SizedBox(height: 12),
                        _buildPdfDetailRow(
                          ttf,
                          'Descrição:',
                          transaction.description!,
                        ),
                      ],

                      pw.SizedBox(height: 12),

                      // ID da Transação
                      _buildPdfDetailRow(
                        ttf,
                        'ID da Transação:',
                        transaction.id,
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                // Informações Legais
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    'Este é um comprovante eletrônico gerado pelo aplicativo Blinq. '
                    'Para verificar a autenticidade deste comprovante, entre em contato com o suporte.',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Salvar o PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/comprovante_${transaction.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Função auxiliar para construir uma linha de detalhe no PDF
  static pw.Widget _buildPdfDetailRow(
    pw.Font font,
    String label,
    String value, {
    bool bold = false,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // Compartilhar o PDF
  static Future<void> sharePdf(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Comprovante de transação Blinq',
    );
  }
}
