/// Converts an arbitrary step name (e.g. `'Another page'`, `'home 2'`) into a
/// snake_case identifier suitable for use as a golden `imageName`.
String sanitizeToSnakeCase(String input) {
  final trimmed = input.trim();
  final withUnderscores = trimmed
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
      .replaceAllMapped(
        RegExp('([a-z0-9])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .toLowerCase();
  return withUnderscores
      .replaceAll(RegExp('_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

/// Sanitizes [stepNames] to snake_case, appending a numeric suffix to any
/// name that collides with an earlier one so all results stay unique.
List<String> sanitizeStepNamesUniquely(List<String> stepNames) {
  final used = <String>{};
  final result = <String>[];

  for (final stepName in stepNames) {
    var sanitized = sanitizeToSnakeCase(stepName);
    if (sanitized.isEmpty) sanitized = 'step';

    var candidate = sanitized;
    var suffix = 2;
    while (!used.add(candidate)) {
      candidate = '${sanitized}_$suffix';
      suffix++;
    }

    result.add(candidate);
  }

  return result;
}
