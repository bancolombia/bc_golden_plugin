# Contributing to bc_golden_plugin

We love your input! We want to make contributing to bc_golden_plugin as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Types of Contributions We Welcome

### 🐛 Bug Reports and Fixes
Help us identify and fix issues in the package, especially those related to:
- Screenshot capture inconsistencies
- CI/CD environment compatibility
- Device configuration issues
- Image comparison threshold problems
- Theme and styling integration bugs

### ✨ Feature Requests and Implementations
Propose or implement enhancements such as:
- New device configurations
- Additional layout types for multi-step testing
- Image comparison improvements
- Better CI/CD integration
- Documentation improvements

### 📖 Documentation
Improve our docs by:
- Adding usage examples
- Clarifying configuration options
- Creating tutorials or guides
- Fixing typos or unclear explanations

### 🤝 Community Support
Help other users by:
- Answering questions in issues
- Sharing best practices
- Providing feedback on proposed changes

## Bug Reports

Before creating a bug report, please check existing issues to avoid duplicates.

### How to Submit a Bug Report

Create an issue with the following information:

**Required Information:**
- **Description**: Clear description of the issue
- **Flutter Version**: Output of `flutter --version`
- **Package Version**: The bc_golden_plugin version you're using
- **Platform**: (iOS, Android, macOS, Windows, Linux, Web)
- **Environment**: Local or CI/CD (specify which: GitHub Actions, GitLab CI, etc.)

**Steps to Reproduce:**
1. Provide a minimal code example
2. Include relevant configuration (flutter_test_config.dart, test setup)
3. Specify device configuration if applicable
4. List steps to trigger the issue

**Expected vs Actual Behavior:**
- What you expected to happen
- What actually happened
- Screenshots or golden image comparisons if relevant

**Additional Context:**
- Relevant logs or error messages
- Any workarounds you've found
- Configuration files (analysis_options.yaml, dart_test.yaml)

### Common Issues to Check First
- **Empty screenshots in CI**: Verify async rendering timeouts
- **Inconsistent device sizes**: Ensure same device config locally and in CI
- **Image differences**: Check difference threshold settings (30% local, 50% CI)
- **Missing golden files**: Run with `--update-goldens` flag first

## Feature Requests

We welcome ideas for improvements! Before submitting:

1. **Check existing issues** to see if someone has already proposed it
2. **Describe the problem** you're trying to solve
3. **Propose a solution** with examples of how it would work
4. **Consider alternatives** and explain why your approach is preferred

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem (e.g., "I'm frustrated when...")

**Describe the solution you'd like**
A clear description of what you want to happen, with code examples.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Additional context**
Relevant examples, screenshots, or references.
```

## Development Setup

### Prerequisites
- Flutter SDK (stable channel recommended)
- Dart SDK (compatible with Flutter version)
- Git
- A code editor (VS Code, Android Studio, etc.)

### Getting Started

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/bc_golden_plugin.git
   cd bc_golden_plugin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run tests to ensure everything works**
   ```bash
   flutter test
   ```

4. **Run golden tests specifically**
   ```bash
   flutter test --tags=golden
   ```

### Project Structure

```
lib/
├── src/
│   ├── capture/       # Screenshot capture logic
│   ├── comparators/   # Image comparison with thresholds
│   ├── config/        # Configuration classes
│   ├── helpers/       # Utilities and logging
│   └── testkit/       # Core testing tools and API
└── bc_golden_plugin.dart  # Public API exports

test/
└── src/               # Unit tests mirroring lib/ structure

example/
└── test/              # Integration tests and usage examples
```

## Code Style and Standards

### Dart Code Formatting
- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format .` before committing
- Our CI will check formatting automatically

### Analysis and Linting
- We use strict analysis options (see `analysis_options.yaml`)
- Run `dart analyze` to check for issues
- Fix all warnings and errors before submitting PR

### Testing Requirements
- All public APIs must have tests
- Golden tests must end with `_golden_test.dart`
- Unit tests should go in `test/` mirroring `lib/` structure
- Aim for high test coverage (check with `flutter test --coverage`)

### Documentation Standards
- Add dartdoc comments for all public APIs
- Use `///` for doc comments
- Include examples in documentation when helpful
- Keep comments clear and concise

### Commit Message Convention
We follow conventional commits for clear history:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(capture): add new grid layout option for multi-step tests
fix(ci): resolve empty screenshot issue in GitHub Actions
docs(readme): add troubleshooting section for CI environments
test(comparators): add threshold validation tests
```

## Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, documented code
   - Add or update tests
   - Update documentation if needed

3. **Test thoroughly**
   ```bash
   flutter test
   flutter test --coverage
   dart analyze
   dart format .
   ```

4. **Update the CHANGELOG.md**
   - Add your changes under "Unreleased" section
   - Follow the existing format

5. **Commit your changes**
   - Use conventional commit messages
   - Keep commits focused and atomic

6. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   - Create pull request on GitHub
   - Fill out the PR template completely
   - Link related issues

7. **Code Review**
   - Respond to feedback promptly
   - Update your PR as needed
   - Ensure all CI checks pass

8. **Merge**
   - Maintainers will merge once approved
   - Your contribution will be in the next release! 🎉

## Running Tests

### All Tests
```bash
flutter test
```

### Golden Tests Only
```bash
flutter test --tags=golden
```

### With Coverage
```bash
flutter test --coverage
```

### Update Golden Files
```bash
flutter test --update-goldens
```

### Specific Test File
```bash
flutter test test/src/capture/golden_screenshot_test.dart
```

## Documentation

### Building API Documentation
```bash
dart doc .
```

Documentation will be generated in `doc/api/` directory.

### Documentation Guidelines
- Keep examples up-to-date
- Test code examples to ensure they work
- Update configuration docs when adding options
- Include migration guides for breaking changes

## Questions or Need Help?

- Check existing [issues](https://github.com/bancolombia/bc_golden_plugin/issues)
- Review the [README](README.md) and [documentation](doc/)
- Check the [example](example/) directory for usage patterns
- Create a new issue for questions not covered elsewhere

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE) file).

---

Thank you for contributing to bc_golden_plugin! 🙏