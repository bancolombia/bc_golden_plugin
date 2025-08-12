// test/logger_test.dart
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

  test('logDebug should call Logger.d with the given message', () {
    logDebug('Test debug');
    verify(mockLogger.d('Test debug')).called(1);
  });

  test('logInfo should call Logger.i with the given message', () {
    logInfo('Test info');
    verify(mockLogger.i('Test info')).called(1);
  });

  test('logWarning should call Logger.w with the given message', () {
    logWarning('Test warning');
    verify(mockLogger.w('Test warning')).called(1);
  });

  test('logError should call Logger.e with the given message', () {
    logError('Test error');
    verify(mockLogger.e('Test error')).called(1);
  });

  test('logVerbose should call Logger.t with the given message', () {
    logVerbose('Test verbose');
    verify(mockLogger.t('Test verbose')).called(1);
  });

  test('logException should call Logger.e with error and stackTrace', () {
    final error = Exception('Something went wrong');
    final stack = StackTrace.current;
    logException(error, stack);

    verify(mockLogger.e(
      'Exception',
      error: error,
      stackTrace: stack,
    )).called(1);
  });

  test('logException should call Logger.e without stackTrace if not provided',
      () {
    final error = Exception('No stack trace');
    logException(error);

    verify(mockLogger.e(
      'Exception',
      error: error,
      stackTrace: null,
    )).called(1);
  });
}
