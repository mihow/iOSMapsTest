# iOSMapsTest — Agent Rules

## What This Is

Test harness comparing 4 map rendering backends in a QEMU iOS Simulator (no Metal GPU).
Research/dev tool, not a shipping app.

## Project Structure

- **Build system:** xcodeproj via [xcodegen](https://github.com/yonaskolb/XcodeGen) (`project.yml`)
- **Bundle ID:** `com.example.iOSMapsTest`
- **Min iOS:** 17.0
- **Swift:** 5.0

## Tabs (4 backends)

| Tab | File | Backend |
|-----|------|---------|
| MapKit | `MapKitTab.swift` | MKMapView (blank in QEMU) |
| MK+Overlay | `MapKitOverlayTab.swift` | MKMapView + MKTileOverlay (blank in QEMU) |
| MapLibre GL | `MapLibreMetalTab.swift` | MapLibre OpenGL ES via static xcframework |
| Leaflet | `LeafletTab.swift` | WKWebView + Leaflet.js |

**Note:** `MapLibreMetalTab.swift` is a misnomer from early development — it uses the OpenGL drawable renderer, not Metal.

## Architecture

- `iOSMapsTestApp.swift` — TabView, defaults to MapLibre GL tab
- `DiagnosticsLog` — `@Observable` model, shared via `.environment()`, tracks GPU capabilities + log entries
- `TestContent` — shared coordinates (Portland, OR), OSM tile URL, GeoJSON loaders
- Each tab is self-contained — no shared map protocol

## Commands

```bash
# Build, install, launch on simulator
bash scripts/build.sh

# Regenerate xcodeproj after editing project.yml
xcodegen generate

# Run tests
xcodebuild -project iOSMapsTest.xcodeproj \
  -scheme iOSMapsTest \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone 16e" \
  test
```

## MapLibre xcframework

Not checked into git (617 MB). Must be built from source or downloaded:

```bash
# In a maplibre-native checkout (with submodules):
bazel build //platform/ios:MapLibre.static --//:renderer=drawable
# Extract to: MapLibre.xcframework/ in project root
```

## Dependencies

- [MapLibre Native](https://github.com/maplibre/maplibre-native) — OpenGL static xcframework (local, not SPM)
- [Leaflet.js](https://leafletjs.com/) 1.9.4 — loaded from CDN in `leaflet.html`
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — generates `.xcodeproj` from `project.yml`

## Rules

- No personal paths, credentials, or VM-specific references in code
- Keep each tab self-contained
- Prefer structs over classes
- `@Observable` for shared state
- No force unwraps
