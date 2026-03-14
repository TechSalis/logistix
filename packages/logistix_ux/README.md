# Logistix UX

A premium, enterprise-level design system for Logistix applications. Built with beautiful animations, reactive UX, and fast, expressive, crisp behaviors.

## Features

### 🎨 Design Tokens
- **Colors**: Comprehensive color palette with semantic colors
- **Spacing**: Consistent spacing scale based on 4px unit
- **Radii**: Border radius tokens for consistent rounded corners
- **Shadows**: Elevation shadows for depth
- **Durations**: Animation timing constants

### ✍️ Typography
- Complete text style system with display, heading, body, label, and caption styles
- Premium font weights and letter spacing
- Optimized line heights for readability

### 🎭 Theme
- Comprehensive Material 3 theme configuration
- Consistent component theming
- Easy to customize and extend

### 🔧 Extensions
- **Context Extensions**: Quick access to theme, media query, navigation, and more
- **Color Extensions**: Lighten, darken, and color utilities
- **Number Extensions**: Duration helpers, spacing widgets, padding helpers
- **String Extensions**: Validation, formatting, and string manipulation

### ✨ Animations
- **Animation Constants**: Carefully crafted curves and durations
- **AnimatedScaleTap**: Premium tactile feedback on tap
- **SlideFadeTransition**: Smooth page and widget transitions
- **SlideFadePageRoute**: Pre-built page route with animations

### 🧩 Components

#### Buttons
- **LogistixButton**: Premium button with variants (primary, secondary, outline, ghost, destructive)
- Built-in loading states
- Scale animation on tap
- Icon support

#### Cards
- **LogistixCard**: Basic card with consistent styling
- **LogistixHeaderCard**: Card with header section
- Optional tap interactions with scale animation

#### Shimmer Loading
- **LogistixShimmer**: Base shimmer wrapper
- **ShimmerBox**: Box placeholder
- **ShimmerCircle**: Circle/avatar placeholder
- **ShimmerText**: Text line placeholder
- **ShimmerCard**: Pre-built card skeleton
- **ShimmerListItem**: Pre-built list item skeleton
- **ShimmerTableRow**: Pre-built table row skeleton

#### Spacing
- **Gap**: Semantic spacing widget
- **VGap**: Vertical spacing
- **HGap**: Horizontal spacing
- Pre-defined sizes (xxs, xs, sm, md, lg, xl, xxl)

### 📱 Responsive Utilities
- Breakpoint constants
- Responsive widget builder
- Helper functions for responsive values

## Usage

### Import the package
```dart
import 'package:logistix_ux/logistix_ux.dart';
```

### Apply the theme
```dart
MaterialApp(
  theme: LogistixTheme.lightTheme,
  home: MyApp(),
)
```

### Use design tokens
```dart
Container(
  padding: EdgeInsets.all(LogistixSpacing.md),
  decoration: BoxDecoration(
    color: LogistixColors.surface,
    borderRadius: LogistixRadii.borderRadiusCard,
    boxShadow: LogistixShadows.card,
  ),
)
```

### Use extensions
```dart
// Context extensions
context.colorScheme.primary
context.textTheme.headlineLarge
context.pushNamed('/home')

// Number extensions
16.0.heightBox
LogistixSpacing.md.paddingAll

// String extensions
'hello'.capitalize
email.isValidEmail
```

### Use components
```dart
// Button
LogistixButton(
  onPressed: () {},
  variant: ButtonVariant.primary,
  size: ButtonSize.medium,
  isLoading: false,
  icon: Icon(Icons.send),
  child: Text('Send'),
)

// Card
LogistixCard(
  onTap: () {},
  child: Text('Content'),
)

// Shimmer loading
LogistixShimmer(
  enabled: isLoading,
  child: ShimmerCard(),
)

// Spacing
Column(
  children: [
    Text('Title'),
    VGap.md(),
    Text('Content'),
  ],
)
```

### Use animations
```dart
// Scale tap animation
AnimatedScaleTap(
  onTap: () {},
  child: MyWidget(),
)

// Slide fade transition
SlideFadeTransition(
  visible: isVisible,
  direction: SlideDirection.up,
  child: MyWidget(),
)

// Page route
Navigator.push(
  context,
  SlideFadePageRoute(
    child: NextPage(),
    direction: SlideDirection.left,
  ),
)
```

## Design Philosophy

Logistix UX is designed to feel **premium and enterprise-level** with:
- ✨ Beautiful, smooth animations
- ⚡ Fast and responsive interactions
- 🎯 No loading indicators - use shimmer effects instead
- 💎 Crisp, expressive behaviors
- 🎨 Consistent design language

## Customization

All design tokens can be easily customized by modifying the values in the respective token files:
- `src/tokens/colors.dart`
- `src/tokens/spacing.dart`
- `src/tokens/radii.dart`
- `src/tokens/shadows.dart`
- `src/tokens/durations.dart`
