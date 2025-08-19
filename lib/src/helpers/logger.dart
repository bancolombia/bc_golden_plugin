import 'package:logger/logger.dart';

final LogPrinter _prettyPrinter = PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 5,
  lineLength: 50,
  colors: true,
  printEmojis: true,
);

Logger logger = Logger(
  level: Level.debug,
  printer: _prettyPrinter,
);

void setLogLevel(Level level) {
  logger = Logger(level: level, printer: _prettyPrinter);
}

void log(
  Level level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  logger.log(level, message, error: error, stackTrace: stackTrace);
}

void logDebug(String message) => log(Level.debug, message);
void logInfo(String message) => log(Level.info, message);
void logWarning(String message) => log(Level.warning, message);
void logError(String message) => log(Level.error, message);
void logVerbose(String message) => log(Level.trace, message);

void logException(Object error, [StackTrace? stackTrace]) {
  log(Level.error, 'Exception', error: error, stackTrace: stackTrace);
}
