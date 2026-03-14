# iOSMapsTest — QEMU Map Rendering Results

Tested on: QEMU macOS Sonoma VM, iOS 18.3.1 Simulator (iPhone SE 3rd gen)
No Metal GPU available. OpenGL ES 2.0/3.0 available (software renderer).

## Backend Comparison

| Backend | Renders? | Tile Source | Renderer | Notes |
|---------|----------|-------------|----------|-------|
| MapKit (MKMapView) | No — blank/beige | Apple Maps | Metal (required) | Metal unavailable in QEMU |
| MapKit + MKTileOverlay | No — blank/beige | OSM raster | Metal (required) | MKMapView rendering broken regardless of tile source |
| MapLibre GL (OpenGL) | Yes | OSM raster | OpenGL ES 3.0 | Built from source with Bazel `--//:renderer=drawable` |
| Leaflet.js (WKWebView) | Yes | OSM raster | Software (WebKit) | No GPU dependency |

## Key Findings

1. **MKMapView is unusable in QEMU** — it requires Metal for all rendering, even with custom tile overlays
2. **MapLibre GL works via OpenGL ES** — the `drawable` renderer uses OpenGL instead of Metal. Built as a static xcframework (409 MB sim slice). Supports vector tiles, raster tiles, GeoJSON overlays, and custom styles.
3. **WKWebView + Leaflet.js works** — software rendering in WebKit bypasses Metal entirely. Good for simple tile display but limited compared to native map SDKs.
4. **OpenGL ES 3.0 is available** in the QEMU iOS Simulator via Apple software renderer

## Recommendation

For iOS apps targeting QEMU simulator testing, use **MapLibre GL with the OpenGL renderer**. It provides the closest feature parity to MapKit (annotations, overlays, gestures, camera control) while working without Metal. Fall back to Leaflet/WKWebView for simpler use cases.

## Build

```bash
# One-command build, install, launch
bash scripts/build.sh

# MapLibre xcframework was built with (in a maplibre-native checkout):
# bazel build //platform/ios:MapLibre.static --//:renderer=drawable
```
