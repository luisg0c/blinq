import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';

/// Serviço central para gerenciar a inicialização e instâncias do Firebase
class FirebaseService extends GetxService {
  final logger = AppLogger('FirebaseService');
  
  /// Inicializa os serviços do Firebase
  Future<FirebaseService> init() async {
    try {
      logger.info('Inicializando Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      logger.info('Firebase inicializado com sucesso');
      return this;
    } catch (e, stackTrace) {
      logger.error('Erro ao inicializar Firebase', e, stackTrace);
      rethrow;
    }
  }
}