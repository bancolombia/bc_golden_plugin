# Changelog
## 3.0.0
- **Breaking:** Removed the `logger` dependency to avoid version conflicts with consumers using a different `logger` version. Logging is now handled internally via `debugPrint`, and `Level` is now defined and exported by this package instead of `package:logger`. Existing `logLevel: Level.xxx` usages keep working unchanged; only a direct dependency on `package:logger`'s own `Level` type would need updating.

## 2.0.3
- Add `settleAfterPump` in `bcWidgetMatchesImage`.

## 2.0.2
- Add `currentPackage` parameter to `loadConfiguration` function.

## 2.0.1
- Update device resolutions.
- Update asset loader.

## 2.0.0
- Updated `logger` to `2.7.0`.
- Updated `file` to `7.0.1`.
- Updated `flutter_lints` to `6.0.0`.
- Updated `dart_code_linter` to `4.0.2`.

## 2.0.0-alpha.5
- Reverted `logger` to `1.0.0`.

## 2.0.0-alpha.4
- Deprecated `bc_golden_test`
- Added `BcGoldenDevice`.
- Added `animations` support.
- Added `multiple screens` support.

## 1.5.0
- Update to flutter `>= 3.27.0`.
- Minor patch fixes.

## 1.4.0
- Update dependencies to be compatible with flutter 3.24 and removed `cupertino_icons`.
- Changed the getters/setters in the `BcGoldenConfiguration` file.

## 1.3.1
- Update README documentation.

## 1.3.0
- Release package to pub.dev.

## 1.2.0
- Release package on github.
