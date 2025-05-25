import 'package:get/get.dart';
import '../../domain/usecases/generate_qr_usecase.dart';
import '../../domain/usecases/parse_qr_usecase.dart';

/// Binding para geração e leitura de QR Code de transferências.
class QrBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando QrBinding...');

    // Use Cases para QR Code
    Get.lazyPut<GenerateQrUseCase>(() => GenerateQrUseCase());
    Get.lazyPut<ParseQrUseCase>(() => ParseQrUseCase());

    print('✅ QrBinding inicializado');
  }
}