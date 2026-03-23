#!/usr/bin/env bash
# =========================================================================
# Logistix Whitelabel Script
# =========================================================================
# This script automates the process of converting the Logistix app into a 
# custom whitelabel application. It replaces names, bundle identifiers,
# environment variables, and generates your icons and splash screens.
#
# PREREQUISITES:
# - Flutter and Dart should be installed and available in your PATH.
# - Ensure that any custom icons are placed in:
#   1. app/whitelabel_assets/icon.png
# =========================================================================

set -e

# --- CONFIGURATION VARIABLES ---
# Change these values to match your target whitelabel application
APP_NAME="Logistix"
BUNDLE_ID="com.techsalis.logistix"

# --- ENVIRONMENT VARIABLES (.env) ---
ENV_HOST="0.0.0.0:4000"
ENV_SENTRY_DSN=""
ENV_ENVIRONMENT="production"
ENV_CONTACT_SUPPORT_URL="https://wa.me/23409069184604?text=%E2%80%8E%20Hi%20there.%0A"

echo "========================================================="
echo "   🚀 Starting Whitelabel Process for $APP_NAME"
echo "========================================================="

# 1. Update the `.env` file for the app
echo "📝 Updating application .env variables..."
cat <<EOF > app/.env
HOST=$ENV_HOST
SENTRY_DSN="$ENV_SENTRY_DSN"
ENVIRONMENT=$ENV_ENVIRONMENT
CONTACT_SUPPORT_URL=$ENV_CONTACT_SUPPORT_URL
EOF
echo "✅ .env file successfully overwritten."

# 2. Activate `rename` pub package for safely modifying native projects
echo "📦 Installing globally the 'rename' package..."
dart pub global activate rename

export PATH="$PATH":"$HOME/.pub-cache/bin"

# Navigate into the main app module
cd app || exit 1

# 3. Change iOS/Android App Name and Bundle Identifier
echo "🔤 Changing Application Name to '$APP_NAME'..."
rename setAppName --targets ios,android --value "$APP_NAME"

echo "🆔 Changing Bundle Identifier to '$BUNDLE_ID'..."
rename setBundleId --targets ios,android --value "$BUNDLE_ID"

# 4. Generate Launcher Icons (via flutter_launcher_icons package configured in flutter_launcher_icons.yaml)
echo "🖼️ Generating Custom Launcher Icons..."
flutter pub get
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml

# 5. Generate Native Splash Screen (via flutter_native_splash configured in flutter_native_splash.yaml)
echo "💧 Generating Application Splash Screen..."
dart run flutter_native_splash:create --path=flutter_native_splash.yaml

# 6. Conclusion
echo "========================================================="
echo "   🎉 Whitelabeling Complete! The app is now: $APP_NAME"
echo "========================================================="
echo "Note: If you encounter XCode caching issues for icons, clean your build:"
echo "      flutter clean && flutter pub get"
echo ""
echo "To further customize other specific textual assets (e.g. Terms of Service URL,"
echo "Company Name in drawer), search the codebase for 'Logistix' or constants."
