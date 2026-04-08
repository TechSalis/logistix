# Logistix — Mobile App

A Flutter monorepo for the **Logistix** logistics platform. The app serves two user roles — **Riders** (delivery drivers) and **Dispatchers** (company admins) — with a shared authentication and onboarding flow.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | BLoC / Cubit |
| Navigation | GoRouter |
| GraphQL Client | graphql_flutter |
| Dependency Injection | GetIt (via `bootstrap`) |
| Code Generation | Freezed, json_serializable, build_runner |
| Monorepo Tooling | Melos |
| Error Monitoring | Sentry |
| Local Storage | HydratedBloc, Flutter Secure Storage |

---

## Repository Structure

```
logistix/
├── app/                    # Main Flutter application entry point
├── modules/
│   ├── auth/               # Login, registration, session management
│   ├── onboarding/         # Rider & dispatcher onboarding flows
│   ├── rider/              # Rider dashboard, orders, locked state
│   └── dispatcher/         # Dispatcher (company) dashboard
└── packages/
    ├── shared/             # Domain entities, use cases, services, EnvConfig
    └── logistix_ux/        # Design system — colours, typography, components
```

Each **module** is an independent Dart package that self-registers its routes and DI bindings via the `bootstrap` module system. The **`app`** package wires everything together.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.9.2` (stable channel recommended)
- [Dart SDK](https://dart.dev/get-dart) `>=3.9.2`
- [Melos](https://melos.invertase.dev/) (monorepo manager)

---

## Setup

### 1. Install Melos globally

```bash
dart pub global activate melos
```

> Make sure your Dart pub cache bin is on your `PATH`:
> ```bash
> export PATH="$PATH:$HOME/.pub-cache/bin"
> ```

### 2. Clone and install dependencies

```bash
git clone <repo-url>
cd logistix

# Bootstrap the workspace — links all local packages and fetches pub dependencies
melos bootstrap
```

This is equivalent to running `flutter pub get` in every package and setting up local path overrides. You only need to run it once (or after adding a new dependency).

### 3. Run code generation

```bash
melos build
```

This runs `build_runner` across every package that requires it (Freezed, json_serializable, etc.).

> **Shortcut — setup + build in one command:**
> ```bash
> melos run setup
> ```

## Environment Configuration

The app uses a unified environment system driven by `.env` files and `EnvConfig`.

### 1. Setup Environment Files

Copy the templates and configure your local/production settings:
```bash
cp app/.env.example app/.env          # Production settings
cp app/.env.example app/.env.debug    # Local development settings
```

### 2. Running the App

We use `--dart-define-from-file` to inject environment variables at build time.

**Local Development (Debug):**
```bash
flutter run --dart-define-from-file=app/.env.debug
```

**Production Testing:**
```bash
flutter run --release --dart-define-from-file=app/.env
```

### 3. VS Code Integration

Pre-configured launch targets are available in `.vscode/launch.json`:
- **Mobile (Debug)**: Uses `.env.debug` (Localhost)
- **Mobile (Release)**: Uses `.env` (Production)

---

## Common Melos Commands

| Command | Description |
|---|---|
| `melos bootstrap` | Link packages and fetch all dependencies |
| `melos run build` | Run `build_runner` in all packages that need it |
| `melos run setup` | Bootstrap + build in one step |
| `melos run pubupgrade` | Run `flutter pub upgrade` across all packages |

---

## Architecture Overview

```
app (entry point)
 └── AppInitialization       # Sentry, HydratedBloc, DI setup
 └── AppRouter               # Assembles routes from all modules
 └── AppBloc                 # Startup / session rehydration

modules/auth                 # AuthBloc → login, register, token refresh
modules/onboarding           # OnboardingBloc → rider & dispatcher flows
modules/rider                # RiderBloc, RiderLockedBloc → dashboard + locked state
modules/dispatcher           # Dispatcher dashboard

packages/shared
 ├── EnvConfig               # Compile-time env variable accessors
 ├── ClearAppDataUseCase     # Clears tokens, user store, GraphQL cache
 ├── GraphQLService          # Apollo-style GraphQL client wrapper
 └── Entities & DTOs         # Rider, Order, Company, User, …

packages/logistix_ux
 ├── LogistixColors          # Brand colour palette
 ├── LogistixTypography      # Text styles
 └── Shared widgets          # Loaders, error views, toasts, …
```

### Authentication & Role Routing

After login, `AppBloc` determines the user's role and onboarding status, then routes to:

- `/auth` — unauthenticated
- `/onboarding` — authenticated but not yet onboarded
- `/rider` — onboarded rider (shows locked screen if not yet accepted by company)
- `/dispatcher` — onboarded dispatcher

### State Management Pattern

Each feature follows the clean-architecture BLoC pattern:

```
Event → Bloc → UseCase → Repository → DataSource (GraphQL)
                 ↓
              State (Freezed union)
```

---

## Adding a New Module

1. Create a new package under `modules/my_module/`
2. Add it to the `workspace:` list in the root `pubspec.yaml`
3. Implement `MyModule extends Module<RouteBase>` and register routes + DI
4. Register `MyModule()` in `AppInitialization._registerDependencies`
5. Run `melos bootstrap` to link the new package

---

## Environment Variables Reference

| Variable | Description | Default |
|---|---|---|
| `GRAPHQL_URL` | Backend GraphQL endpoint | `http://localhost:4000/graphql` |
| `ENVIRONMENT` | `development` or `production` | `development` |
| `SENTRY_DSN` | Sentry project DSN for error reporting | _(empty — Sentry disabled)_ |
| `CONTACT_SUPPORT_URL` | URL opened by "Contact Support" button | `https://support.logistix.com` |

All variables are accessed via `EnvConfig` in `packages/shared/lib/src/core/config/env_config.dart`.
