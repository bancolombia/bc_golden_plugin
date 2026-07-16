import 'dart:io';

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:bc_golden_lint/src/fixes/replace_with_bc_golden_capture_single_fix.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('replaces bcGoldenTest with BcGoldenCapture.single, keeping args', () async {
    final fixturePath = p.join(
      Directory.current.path,
      'test',
      'fixtures',
      'prefer_bc_golden_capture_fixture.dart',
    );
    final content = await File(fixturePath).readAsString();

    final result = await resolveFile(path: fixturePath);
    result as ResolvedUnitResult;

    final libraryResult = await result.session.getResolvedLibrary(
      result.libraryElement.firstFragment.source.fullName,
    );
    libraryResult as ResolvedLibraryResult;

    final offset = content.lastIndexOf('bcGoldenTest(');

    final context = CorrectionProducerContext.createResolved(
      libraryResult: libraryResult,
      unitResult: result,
      selectionOffset: offset,
      selectionLength: 'bcGoldenTest'.length,
    );

    final producer = ReplaceWithBcGoldenCaptureSingle(context: context);
    final builder = ChangeBuilder(session: result.session);

    await producer.compute(builder);
    final change = builder.sourceChange;

    expect(change.edits, hasLength(1));
    final fileEdit = change.edits.single;
    expect(fileEdit.edits, hasLength(1));

    final edit = fileEdit.edits.single;
    final updated = content.replaceRange(
      edit.offset,
      edit.offset + edit.length,
      edit.replacement,
    );

    expect(
      updated,
      contains(
        "BcGoldenCapture.single('a golden test', () {}, shouldUseRealShadows: false);",
      ),
    );
    expect(updated, isNot(contains('void f() {\n  bcGoldenTest(')));
  });
}
