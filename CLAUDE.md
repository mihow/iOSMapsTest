# iOSMapsTest — Agent Rules

## Purpose
Test harness comparing map rendering backends in QEMU iOS Simulator (no Metal GPU).
This is a research/dev tool, not a shipping app.

## Swift Rules
- Swift 6 strict concurrency; async/await for all async ops
- Prefer structs over classes
- @Observable for shared state (DiagnosticsLog)
- Never force unwrap (!)
- Extract views > 100 lines into separate files

## Project Rules
- SPM-based — no .xcodeproj
- Simulator builds only — no code signing
- Bundle ID: com.example.iOSMapsTest
- Build: `bash scripts/build.sh`
- Screenshots: `bash scripts/test_screens.sh`

## Architecture
- TabView with one tab per map backend
- Each tab is independent — no shared MapRenderer protocol
- DiagnosticsLog is @Observable, shared via .environment()
- Backends: MapKit, MapKit+TileOverlay, MapLibre(Metal/SPM), Leaflet(WKWebView), MapLibre(OpenGL — Phase 2)

## Testing
- Unit tests for DiagnosticsLog and TestContent models
- Visual testing via screenshot tour (scripts/test_screens.sh)
- Run tests: xcodebuild -scheme iOSMapsTest -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" test

## Key Constraint
- MKMapView does NOT render in QEMU (Metal unavailable)
- MapLibre SPM (Metal binary) also expected to fail
- Leaflet/WKWebView is the known-working reference
- MapLibre OpenGL build (Phase 2) is the primary experiment
