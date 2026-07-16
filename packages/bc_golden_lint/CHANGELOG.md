## 0.1.0

- Initial release.
- Adds an `analysis_server_plugin` quick assist, "Convert to separate BcGoldenCapture.single tests", that rewrites a `BcGoldenCapture.multiple(...)` call into independent `BcGoldenCapture.single(...)` calls, one per `GoldenStep`.
- Adds the `golden_image_name_no_extension` lint rule, flagging `bcWidgetMatchesImage` calls whose `imageName` includes a `.png` extension.
- Adds the `prefer_bc_golden_capture` lint rule with an automatic fix, flagging calls to the deprecated `bcGoldenTest` and replacing them with `BcGoldenCapture.single`.
