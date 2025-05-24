import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Caso de uso para compartilhar um comprovante (PDF gerado).
class ShareReceiptUseCase {
  Future<void> execute(File file) async {
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado para compartilhamento');
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Comprovante de transação gerado via Blinq.',
    );
  }
}
