import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log_package;

/// Classe para logging consistente em toda a aplicação
class AppLogger {
  final String _tag;
  late log_package.Logger _logger;

  // Niveles de log disponíveis
  static const _defaultLogLevel = log_package.Level.info;
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  // Configuração global
  static bool _debugMode = kDebugMode;
  static log_package.Level _logLevel = _defaultLogLevel;

  /// Construtor
  AppLogger(this._tag) {
    _logger = log_package.Logger(
      printer: log_package.PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: _logLevel,
    );
  }

  /// Configura o modo de debug global
  static void setDebugMode(bool value) {
    _debugMode = value;
  }

  /// Configura o nível de log global
  static void setLogLevel(log_package.Level level) {
    _logLevel = level;
  }

  /// Log verbose (detalhado)
  void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_debugMode) return;
<<<<<<< HEAD
    _logger.v('[$_tag] $message', error: error, stackTrace: stackTrace);
=======
    _logger.v('[$_tag] $message', error, stackTrace);
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  }

  /// Log de debug
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_debugMode) return;
<<<<<<< HEAD
    _logger.d('[$_tag] $message', error: error, stackTrace: stackTrace);
=======
    _logger.d('[$_tag] $message', error, stackTrace);
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  }

  /// Log informativo
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
<<<<<<< HEAD
    _logger.i('[$_tag] $message', error: error, stackTrace: stackTrace);
=======
    _logger.i('[$_tag] $message', error, stackTrace);
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  }

  /// Log de aviso
  void warn(String message, [dynamic error, StackTrace? stackTrace]) {
<<<<<<< HEAD
    _logger.w('[$_tag] $message', error: error, stackTrace: stackTrace);
=======
    _logger.w('[$_tag] $message', error, stackTrace);
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  }

  /// Log de erro
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
<<<<<<< HEAD
    _logger.e('[$_tag] $message', error: error, stackTrace: stackTrace);
=======
    _logger.e('[$_tag] $message', error, stackTrace);
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  }

  /// Log de erro crítico/fatal
  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
<<<<<<< HEAD
    _logger.wtf('[$_tag] $message', error: error, stackTrace: stackTrace);
  }
}
=======
    _logger.wtf('[$_tag] $message', error, stackTrace);
  }
}
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
