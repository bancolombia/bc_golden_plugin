// Stand-in for bc_golden_plugin's API, so this fixture resolves without a
// dependency on the real package.
@Deprecated('Use BcGoldenCapture.single instead')
void bcGoldenTest(
  String description,
  Function test, {
  bool shouldUseRealShadows = true,
}) {}

class BcGoldenCapture {
  static void single(String description, Function test) {}
}

void f() {
  bcGoldenTest('a golden test', () {}, shouldUseRealShadows: false);
}
