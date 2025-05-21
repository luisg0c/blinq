import 'package:get/get.dart';
import '../../../domain/usecases/generate_qr_usecase.dart';
import '../../../domain/usecases/parse_qr_usecase.dart';

/// Binding para geração e leitura de QR Code de transferências.
class QrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GenerateQrUseCase());
    Get.lazyPut(() => ParseQrUseCase());
  }
}
