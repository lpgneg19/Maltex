# Contributing to AppleSword

First off, thank you for considering contributing to AppleSword! It's people like you that make AppleSword a great tool for everyone.

This project is a native macOS download manager built with SwiftUI and powered by the `aria2` engine.

## Code of Conduct

By participating in this project, you are expected to uphold our [Code of Conduct](./CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs

- **Check if the bug has already been reported** by searching on the [GitHub Issues](https://github.com/agalwood/Motrix/issues) page.
- If you can't find an open issue addressing the problem, [open a new one](https://github.com/agalwood/Motrix/issues/new).
- Use a clear and descriptive title.
- Describe the exact steps which reproduce the problem in as many details as possible.

### Suggesting Enhancements

- **Check if the enhancement has already been suggested.**
- [Open a new issue](https://github.com/agalwood/Motrix/issues/new) and describe the enhancement you would like to see, and why it would be useful.

### Pull Requests

1. **Fork the repository** and create your branch from `master`.
2. **If you've added code that should be tested, add tests.**
3. **Ensure the test suite passes.**
4. **Make sure your code lints** and follows the existing project style.
5. **Issue that pull request!**

## Local Development Setup

### Prerequisites

- macOS 14.0+
- Xcode 15.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/agalwood/Motrix.git
   cd Motrix
   ```

2. Generate the Xcode Project:
   AppleSword uses `XcodeGen` to manage the project file. Do not commit `.xcodeproj` files if they are generated locally.
   ```bash
   xcodegen generate
   ```

3. Open the project:
   ```bash
   open AppleSword.xcodeproj
   ```

### Coding Standards

- We use **Swift 6**.
- Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- Use 4 spaces for indentation (as configured in `project.yml`).
- Keep UI components small and reusable.

## Project Structure

- `AppleSword/`: Main application source code.
- `AppleSwordExtension/`: Safari Web Extension source code.
- `extra/`: Bundled `aria2c` binaries and default configurations.
- `project.yml`: XcodeGen project specification.

## Translation

AppleSword aims to be accessible to everyone. Translations are managed via `.xcstrings` files in the Xcode project. Contributions to localizations are highly appreciated!

---

*Happy Coding!*
