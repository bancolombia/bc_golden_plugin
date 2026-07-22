import 'package:bc_golden_plugin/src/helpers/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DebugPrintCallback originalDebugPrint;
  late List<String> prints;

  setUp(() {
    originalDebugPrint = debugPrint;
    prints = [];
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) prints.add(message);
    };
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
    setLogLevel(Level.nothing);
  });

  test('log does not print when level is below the current log level', () {
    setLogLevel(Level.error);
    log(Level.debug, 'Debug message');
    expect(prints, isEmpty);
  });

  test('log prints when level is at or above the current log level', () {
    setLogLevel(Level.debug);
    log(Level.info, 'Info message');
    expect(prints, hasLength(1));
    expect(prints.single, contains('Info message'));
  });

  test('log includes error and stackTrace when provided', () {
    setLogLevel(Level.debug);
    final error = Exception('Test error');
    final stackTrace = StackTrace.current;

    log(Level.error, 'Failure', error: error, stackTrace: stackTrace);

    expect(prints.single, contains('Failure'));
    expect(prints.single, contains(error.toString()));
    expect(prints.single, contains(stackTrace.toString()));
  });

  test('logDebug logs at Level.debug', () {
    setLogLevel(Level.debug);
    logDebug('Debug message');
    expect(prints.single, contains('[DEBUG] Debug message'));
  });

  test('logInfo logs at Level.info', () {
    setLogLevel(Level.info);
    logInfo('Info message');
    expect(prints.single, contains('[INFO] Info message'));
  });

  test('logWarning logs at Level.warning', () {
    setLogLevel(Level.warning);
    logWarning('Warning message');
    expect(prints.single, contains('[WARNING] Warning message'));
  });

  test('logError logs at Level.error', () {
    setLogLevel(Level.error);
    logError('Error message');
    expect(prints.single, contains('[ERROR] Error message'));
  });

  test('logVerbose logs at Level.verbose', () {
    setLogLevel(Level.verbose);
    logVerbose('Verbose message');
    expect(prints.single, contains('[VERBOSE] Verbose message'));
  });

  test('logException logs at Level.error with the error attached', () {
    setLogLevel(Level.error);
    final error = Exception('Boom');
    logException(error);
    expect(prints.single, contains('Exception'));
    expect(prints.single, contains(error.toString()));
  });

  test('setLogLevel(nothing) suppresses all logs', () {
    setLogLevel(Level.nothing);
    logError('Should not print');
    expect(prints, isEmpty);
  });
}
