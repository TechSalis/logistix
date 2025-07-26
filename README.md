# Logistix App

A dispatch app for vendors and users built with Flutter, Riverpod, and Clean Architecture.

## Features
- Rider tracking
- Chat
- Real-time location
- Create Delivery
- Customized delivery flows; Food, Groceries and Errands
- Find Rider
- Manage Your Orders
- Notifications and Realtime Updates

## Architecture
- Feature-based folder structure
- Riverpod and ephemeral state management
- Repository Pattern
- SOLID principles
- REST APIs and (Ably & Supabase) Websockets
- FCM for notifications, alerts and status (data) updates


## Getting Started

### Build and Run

- flutter pub get
- dart run build_runner build --delete-conflicting-outputs


## App Run / Build Commands

- flutter run --flavor dev -t lib/main.dev.dart
- flutter run --flavor prod -t lib/main.dart

