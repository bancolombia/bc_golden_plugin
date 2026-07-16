import 'package:bc_golden_lint/src/utils/name_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('sanitizeToSnakeCase', () {
    test('lowercase single word stays the same', () {
      expect(sanitizeToSnakeCase('home'), 'home');
    });

    test('space separated words with a number', () {
      expect(sanitizeToSnakeCase('home 2'), 'home_2');
    });

    test('capitalized words become lowercase snake_case', () {
      expect(sanitizeToSnakeCase('Another page'), 'another_page');
    });

    test('punctuation is collapsed into a single underscore', () {
      expect(sanitizeToSnakeCase('Step: 1 - Confirm'), 'step_1_confirm');
    });

    test('camelCase is split into separate words', () {
      expect(sanitizeToSnakeCase('homePage'), 'home_page');
    });
  });

  group('sanitizeStepNamesUniquely', () {
    test('appends numeric suffixes to colliding names', () {
      expect(
        sanitizeStepNamesUniquely(['Home!', 'Home?', 'Home?']),
        ['home', 'home_2', 'home_3'],
      );
    });

    test('does not suffix names that do not collide', () {
      expect(
        sanitizeStepNamesUniquely(['home', 'home 2', 'Another page']),
        ['home', 'home_2', 'another_page'],
      );
    });
  });
}
