# bc_golden_lint

A [`custom_lint`](https://pub.dev/packages/custom_lint) plugin for
[`bc_golden_plugin`](https://pub.dev/packages/bc_golden_plugin) that currently
provides a single IDE quick assist:

## Convert to separate BcGoldenCapture.single tests

`BcGoldenCapture.multiple` renders each `GoldenStep` on an independent,
freshly-pumped widget tree and stitches all captured screenshots into **one
combined golden image** — it does not carry state or navigation across
steps, and it does not produce separate golden files per step. It's easy to
reach for `.multiple` expecting it to represent a navigable multi-screen flow
(e.g. a money-transfer flow: enter amount → confirm → success) when that's
not what it does.

This assist gives you a mechanical, non-judgmental way out: place your cursor
inside a `BcGoldenCapture.multiple(...)` call and trigger the quick-fix menu.
It rewrites the call into N independent `BcGoldenCapture.single(...)` calls,
one per `GoldenStep`, each producing its own golden image via
`bcWidgetMatchesImage`.

### Known limitations

- Detection of `BcGoldenCapture.multiple(...)` is purely syntactic (it
  matches on the method/class name, not on resolved types), which keeps the
  assist fast and dependency-free but means an unrelated class with the same
  name would also match.
- The assist only offers the rewrite when the `steps` argument is a literal
  list of `GoldenStep(...)` values. If it's a variable, contains a spread, or
  any other non-literal shape, no assist is offered rather than attempting a
  partial rewrite.
- `GoldenCaptureConfig`'s `device` is the only field carried over into each
  generated `bcWidgetMatchesImage` call; `testName`, `delayBetweenScreens`,
  `layoutType`, `maxScreensPerRow`, and `spacing` don't apply to independent
  single tests and are dropped.
- When a `GoldenStep` has a `setupAction`/`verifyAction`, the generated code
  runs them **after** image capture rather than interleaved with the
  pump/settle phases the way `.multiple` does internally (`bcWidgetMatchesImage`
  has no equivalent mid-pump hook). The generated code includes a
  `// TODO(bc_golden_lint): review setup/verify ordering` comment so this is
  visible to whoever applies the fix.

This package intentionally does **not** ship a warning-style lint rule for
`.multiple` usage: a heuristic like "different widget types across steps"
produces false positives on legitimate usage (e.g. comparing several
distinct screens side by side), so misuse detection is left to human
judgment — this assist only offers an escape hatch once you've decided you
want separate tests.
