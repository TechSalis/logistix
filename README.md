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

### Setup

**Generate Firebase configuration using fluttur_fire cli**

- Setup:
    - firebase_options_dev.dart file in [lib/](lib) directory
    - firebase_options_prod.dart file in [lib/](lib) directory
    
- Create [dev] and [prod] folders under [android/app/src](android/app/src) and place respective google-services.json files in each newly created folder

- Place GoogleService-Info-dev.plist files in [ios/Runner](ios/Runner) directory
- Place GoogleService-Info-prod.plist files in [ios/Runner](ios/Runner) directory


### Build and Run

- flutter pub get
- dart run build_runner build --delete-conflicting-outputs


## App Run / Build Commands

- flutter run --flavor dev -t lib/main.dev.dart
- flutter run --flavor prod -t lib/main.dart
