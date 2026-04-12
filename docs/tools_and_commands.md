# Mobile Tools & Commands

This document covers the essential tools and commands used to manage the Logistix mobile monorepo.

---

## 1. Melos (Monorepo Manager)
Melos is used to manage multiple packages within the same repository.

### Essential Commands
- `melos bootstrap`: Links all local packages together and fetches all `pub` dependencies. Run this after cloning the repo or after adding a new internal dependency.
- `melos run build`: Runs `build_runner` across all packages that require it (e.g., packages using Drift). Note: Business logic DTOs and States do **not** require this due to our Zero-Generation architecture.
- `melos run setup`: A combination of `bootstrap` and `build`.
- `melos run analyze`: Runs `dart analyze` across the entire workspace.
- `melos clean`: Cleans the build artifacts and cache for all packages.

---

## 2. FVM (Flutter Version Management)
The project uses specific Flutter versions for consistency.

- **Check Version**: View `.fvmrc` at the root.
- **Run Commands**: Prefix with `fvm` (e.g., `fvm flutter run`) or ensure your editor is configured to use the FVM SDK path.
- **SDK Path**: Usually `/Users/enrico/fvm/versions/3.41.6` (verify with `fvm list`).

---

## 3. Environment Injection
Environment variables are injected at build time using `--dart-define-from-file`.

- **Debug**: `flutter run --dart-define-from-file=app/.env.debug`
- **Release**: `flutter build apk --dart-define-from-file=app/.env`

### Accessing Env Vars
Access variables safely through `EnvConfig` in `packages/shared`:
```dart
final baseUrl = EnvConfig.get('GRAPHQL_URL');
```

---

## 4. Code Generation
While we prioritize Zero-Generation, some libraries still require it:

- **Drift (Database)**: Generates the SQLite schema and helpers in `shared`.
- **Flutter Gen**: Generates asset paths for icons and images in modules.

When changes are made to these files, run:
```bash
melos run build
```

---

## 5. VS Code Tips
- **Multi-root Workspace**: Open the root folder in VS Code.
- **Extensions**: Install "Flutter", "Dart", and "Melos" extensions.
- **Launch Configurations**: Use the "Run & Debug" sidebar to select pre-configured targets like "Mobile (Debug)".
