// ignore_for_file: missing-test-assertion
import 'package:bc_golden_plugin/src/helpers/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<Logger>()])
import 'logger_test.mocks.dart';

void main() {
  late MockLogger mockLogger;

  setUp(() {
    mockLogger = MockLogger();
    logger = mockLogger;
  });

  tearDown(() {
    logger = Logger(
      level: Level.debug,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
      ),
    );
  });

  test('log should call Logger.log with the correct parameters', () {
    const message = 'Test log';
    final error = Exception('Test error');
    final stackTrace = StackTrace.current;

    log(Level.info, message, error: error, stackTrace: stackTrace);
    verify(
      mockLogger.log(Level.info, message, error, stackTrace),
    ).called(1);
  });

  test('logDebug should call log with Level.debug', () {
    const message = 'Debug message';
    logDebug(message);
    verify(mockLogger.log(Level.debug, message)).called(1);
  });

  test('logInfo should call log with Level.info', () {
    const message = 'Info message';
    logInfo(message);
    verify(mockLogger.log(Level.info, message)).called(1);
  });

  test('logWarning should call log with Level.warning', () {
    const message = 'Warning message';
    logWarning(message);
    verify(mockLogger.log(Level.warning, message)).called(1);
  });

  test('logError should call log with Level.error', () {
    const message = 'Error message';
    logError(message);
    verify(mockLogger.log(Level.error, message)).called(1);
  });

  test('logVerbose should call log with Level.trace', () {
    const message = 'Verbose message';
    logVerbose(message);
    verify(mockLogger.log(Level.verbose, message)).called(1);
  });
}
