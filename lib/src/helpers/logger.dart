import 'package:logger/logger.dart';

var logger = Logger(
  level: Level.debug,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
  ),
);

void setLogLevel(Level level) {
  logger = Logger(
    level: level,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
}

void logDebug(String message) {
  logger.d(message);
}

void logInfo(String message) {
  logger.i(message);
}

void logWarning(String message) {
  logger.w(message);
}

void logError(String message) {
  logger.e(message);
}

void logVerbose(String message) {
  logger.t(message);
}

void logException(Object error, [StackTrace? stackTrace]) {
  logger.e(
    'Exception',
    stackTrace: stackTrace,
    error: error,
  );
}
