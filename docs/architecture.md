# Logistix Mobile Architecture

The Logistix mobile application is built with a focus on **Zero-Generation (build-runner-free business logic)**, modularity, and real-time reliability. It follows Clean Architecture principles adapted for a high-performance Flutter monorepo.

---

## 1. The "Zero-Generation" Pattern
Unlike traditional Flutter projects that rely heavily on `freezed` and `json_serializable`, Logistix utilizes the **Zero-Generation** pattern for all business logic:

- **Manual Data Models**: All Entities and DTOs are implemented manually. This includes `fromJson`, `toJson`, `copyWith`, `==`, and `hashCode`.
- **Manual State Hierarchy**: Cubit/Bloc states use explicit class hierarchies instead of generated unions.
- **Benefits**:
  - **Instant Compilation**: No waiting for `build_runner` during feature development.
  - **Explicit Code**: Clearer debugging and inheritance structures.
  - **Reduced Binary Size**: Fewer generated files and methods.

---

## 2. Core Architectural Layers

### Domain Layer (Packages & Modules)
- **Entities**: Plain Dart objects representing the business domain.
- **Use Cases**: Specific business operations (e.g., `SyncDispatcherDataUseCase`).
- **Repository Interfaces**: Abstract definitions of data access.

### Data Layer
- **Repositories**: Standard implementations that coordinate Local and Remote data sources.
- **SSOT (Single Source of Truth)**: Repositories prioritize local persistence (Drift) as the source of truth for the UI.
- **DataSources**: Remote (GraphQL) and Local (SQLite via Drift).

### Presentation Layer
- **BLoC / Cubit**: Manages UI state and business logic events.
- **Modular Widgets**: UI components organized by feature within their respective modules.

---

## 3. Modular Monorepo (Melos)
The workspace is organized into **Modules** and **Packages**:

- ** Modules (`modules/`)**: Self-contained packages representing a specific user role or feature set (Auth, Dispatcher, Rider, Customer). They register their own routes and DI bindings.
- ** Packages (`packages/`)**: Shared infrastructure (shared utilities, design system).

---

## 4. Session & Sync Lifecycle
Real-time features (Orders, Chat, Riders) are managed by the **SessionCoordinator**:

- **SessionComponent**: A pluggable unit of long-running logic (e.g., a GraphQL Subscription or a background Timer).
- **SessionCoordinator**: Orchestrates the starting/stopping of these components based on the user's authentication and role status.
- **Reactive Updates**: Local DB updates triggered by background components automatically propagate to the UI via Reactive Streams.

---

## 5. Technology Choices
- **Persistence**: [Drift](https://drift.simonbinder.eu/) (SQLite) for high-performance reactive persistence.
- **Networking**: [GraphQL Flutter](https://pub.dev/packages/graphql_flutter) for type-safe API communication and Subscriptions.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for modular declarative routing.
- **Injection**: [GetIt](https://pub.dev/packages/get_it) via a custom `bootstrap` module assembly system.
