import SwiftUI
import MapLibre

struct MapLibreMetalTab: View {
    var body: some View {
        NavigationStack {
            MapLibreOGLContainerView()
                .navigationTitle("ML OpenGL")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapLibreOGLContainerView: View {
    @State private var mapView: MLNMapView?

    private let overviewCenter = CLLocationCoordinate2D(latitude: 45.5150, longitude: -122.6280)
    private let overviewZoom: Double = 10

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapLibreOGLMapView(mapView: $mapView)

            VStack(spacing: 8) {
                Button {
                    guard let map = mapView else { return }
                    map.setCenter(overviewCenter, zoomLevel: overviewZoom, animated: true)
                } label: {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(spacing: 0) {
                    Button {
                        guard let map = mapView else { return }
                        map.setZoomLevel(min(map.zoomLevel + 1, 22), animated: true)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial)
                    }
                    Divider().frame(width: 44)
                    Button {
                        guard let map = mapView else { return }
                        map.setZoomLevel(max(map.zoomLevel - 1, 0), animated: true)
                    } label: {
                        Image(systemName: "minus")
                            .font(.title3.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .shadow(radius: 2)
            .padding(.trailing, 12)
            .padding(.bottom, 80)
        }
    }
}

struct MapLibreOGLMapView: UIViewRepresentable {
    @Binding var mapView: MLNMapView?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MLNMapView {
        let styleURL: URL
        if let localURL = Bundle.main.url(forResource: "osm-raster-style", withExtension: "json") {
            styleURL = localURL
            print("[MapLibre OGL] loading local style: \(localURL)")
        } else {
            styleURL = URL(string: "https://demotiles.maplibre.org/style.json")!
            print("[MapLibre OGL] ⚠️ local style not found, falling back to demo tiles")
        }

        let map = MLNMapView(frame: .zero, styleURL: styleURL)
        map.delegate = context.coordinator
        map.setCenter(
            CLLocationCoordinate2D(latitude: 45.5150, longitude: -122.6280),
            zoomLevel: 10,
            animated: false
        )
        DispatchQueue.main.async { self.mapView = map }
        return map
    }

    func updateUIView(_ uiView: MLNMapView, context: Context) {}

    final class Coordinator: NSObject, MLNMapViewDelegate {
        func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
            print("[MapLibre OGL] ✅ map loaded")
        }
        func mapViewDidFailLoadingMap(_ mapView: MLNMapView, withError error: Error) {
            print("[MapLibre OGL] ❌ \(error)")
        }
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            print("[MapLibre OGL] ✅ style: \(style.name ?? "?"), sources: \(style.sources.count)")
        }
    }
}
