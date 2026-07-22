import 'package:flutter/foundation.dart';

/// ## Level
/// Logging levels for the plugin's internal logger, ordered from most
/// verbose ([Level.verbose]) to fully disabled ([Level.nothing]).
enum Level { verbose, debug, info, warning, error, nothing }

Level _currentLevel = Level.nothing;

void setLogLevel(Level level) {
  _currentLevel = level;
}

bool _shouldLog(Level level) => level.index >= _currentLevel.index;

void log(
  Level level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!_shouldLog(level)) return;

  final buffer = StringBuffer('[${level.name.toUpperCase()}] $message');
  if (error != null) buffer.write('\nError: $error');
  if (stackTrace != null) buffer.write('\n$stackTrace');

  debugPrint(buffer.toString());
}

void logDebug(String message) => log(Level.debug, message);
void logInfo(String message) => log(Level.info, message);
void logWarning(String message) => log(Level.warning, message);
void logError(String message) => log(Level.error, message);
void logVerbose(String message) => log(Level.verbose, message);

void logException(Object error, [StackTrace? stackTrace]) {
  log(Level.error, 'Exception', error: error, stackTrace: stackTrace);
}
