#!/bin/bash
set -e
DEVICE_ID="6CAD5AE3-6BA8-45D2-AFAA-9833A3C0B62C"
BUNDLE_ID="com.example.iOSMapsTest"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Building iOSMapsTest ==="
xcodebuild -project "$PROJECT_DIR/iOSMapsTest.xcodeproj" \
  -scheme iOSMapsTest \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" \
  build 2>&1 | tail -5

APP=$(find ~/Library/Developer/Xcode/DerivedData/iOSMapsTest-*/Build/Products/Debug-iphonesimulator/ \
  -name "iOSMapsTest.app" -maxdepth 1 2>/dev/null | head -1)

if [ -z "$APP" ]; then
  echo "ERROR: .app not found in DerivedData"
  exit 1
fi

echo "=== Installing on simulator ==="
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$DEVICE_ID" "$APP"

echo "=== Launching ==="
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
echo "Done. App: $APP"
