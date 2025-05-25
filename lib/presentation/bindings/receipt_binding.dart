import 'package:get/get.dart';
import '../../../domain/usecases/export_receipt_usecase.dart';
import '../../../domain/usecases/share_receipt_usecase.dart';

/// Binding para gerar e compartilhar comprovantes de transações.
class ReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExportReceiptUseCase());
    Get.lazyPut(() => ShareReceiptUseCase());
  }
}
