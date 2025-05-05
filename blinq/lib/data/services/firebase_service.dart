import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../../firebase_options.dart';
<<<<<<< HEAD
import '../../core/utils/logger.dart';
=======
import '../utils/logger.dart';
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d

/// Serviço central para gerenciar a inicialização e instâncias do Firebase
class FirebaseService extends GetxService {
  final logger = AppLogger('FirebaseService');
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
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
<<<<<<< HEAD
}
=======
}
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
