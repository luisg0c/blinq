import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log_package;

/// Classe para logging consistente em toda a aplicação
class AppLogger {
  final String _tag;
  late log_package.Logger _logger;

  // Niveles de log disponíveis
  static const _defaultLogLevel = log_package.Level.info;

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
    _logger.v('[$_tag] $message', error: error, stackTrace: stackTrace);
  }

  /// Log de debug
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_debugMode) return;
    _logger.d('[$_tag] $message', error: error, stackTrace: stackTrace);
  }

  /// Log informativo
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('[$_tag] $message', error: error, stackTrace: stackTrace);
  }

  /// Log de aviso
  void warn(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w('[$_tag] $message', error: error, stackTrace: stackTrace);
  }

  /// Log de erro
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('[$_tag] $message', error: error, stackTrace: stackTrace);
  }

  /// Log de erro crítico/fatal
  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf('[$_tag] $message', error: error, stackTrace: stackTrace);
  }
}
