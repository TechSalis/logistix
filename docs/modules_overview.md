# Mobile Modules Overview

Logistix is a modular monorepo. Each module is an independent Dart package responsible for a specific domain or user role.

---

## 1. App (`app/`)
The main entry point. 
- **Initialization**: Configures Sentry, HydratedBloc, and kicks off Global DI.
- **Routing**: Combines the route definitions from all other modules into a single `GoRouter` instance.
- **AppBloc**: Manages global session state (Authorized, Unauthorized, Onboarding).

---

## 2. Shared Package (`packages/shared/`)
Common infrastructure used by all modules.
- **Database**: Definitive schema for Drift (SQLite).
- **Network**: GraphQL Service, Auth interceptors, and Sync logic.
- **Config**: Type-safe `EnvConfig` for `.env` access.
- **Common Entities**: Shared models like `User`, `Order`, `Rider`.

---

## 3. Logistix UX (`packages/logistix_ux/`)
The design system.
- **Branding**: Colors, Typography, Spacing.
- **Components**: Standardized buttons, avatars, loaders, and input fields.
- **Animations**: Reusable animation wrappers (Flutter Animate).

---

## 4. Auth Module (`modules/auth/`)
Handles the user session.
- **Login/Register**: Integration with backend auth.
- **Token Management**: Secure storage and automatic token refresh logic.

---

## 5. Dispatcher Module (`modules/dispatcher/`)
The dashboard for company administrators.
- **Orders**: Creation, assignment, and real-time tracking of orders.
- **Chats**: Omnichannel messaging platform (WhatsApp, AI-enabled).
- **Riders**: Monitoring active riders and their performance.

---

## 6. Rider Module (`modules/rider/`)
The app for delivery drivers.
- **Active Orders**: Steps for pickup, transit, and delivery.
- **Map View**: Advanced Google Maps integration for routing.
- **Stale State Management**: Handling "Locked" states for inactive or rejected accounts.

---

## 7. Onboarding Module (`modules/onboarding/`)
User profiling flow for new accounts.
- **Rider Onboarding**: Document uploads and vehicle details.
- **Dispatcher Onboarding**: Company registration and branding.
