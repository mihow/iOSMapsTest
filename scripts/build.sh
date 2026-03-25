#!/bin/bash
set -e

BUNDLE_ID="com.example.iOSMapsTest"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Find a booted simulator, or fall back to first available iPhone 16e
DEVICE_ID=$(xcrun simctl list devices booted -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d.get('state') == 'Booted':
            print(d['udid']); sys.exit(0)
" 2>/dev/null)

if [ -z "$DEVICE_ID" ]; then
    echo "No booted simulator found. Booting iPhone 16e..."
    DEVICE_ID=$(xcrun simctl list devices available -j | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if 'iPhone 16e' in d.get('name', '') and d.get('isAvailable'):
            print(d['udid']); sys.exit(0)
")
    if [ -z "$DEVICE_ID" ]; then
        echo "ERROR: No iPhone 16e simulator found."
        exit 1
    fi
    xcrun simctl boot "$DEVICE_ID"
fi

echo "=== Building iOSMapsTest (simulator: $DEVICE_ID) ==="
xcodebuild -project "$PROJECT_DIR/iOSMapsTest.xcodeproj" \
  -scheme iOSMapsTest \
  -sdk iphonesimulator \
  -destination "id=$DEVICE_ID" \
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
