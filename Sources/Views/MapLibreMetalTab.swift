import SwiftUI
import MapLibre

struct MapLibreMetalTab: View {
    var body: some View {
        NavigationStack {
            MapLibreOGLMapView()
                .navigationTitle("ML OpenGL")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapLibreOGLMapView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MLNMapView {
        let styleURL = URL(string: "https://demotiles.maplibre.org/style.json")!
        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        mapView.delegate = context.coordinator
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: 45.5150, longitude: -122.6280),
            zoomLevel: 12,
            animated: false
        )
        print("[MapLibre OGL] MLNMapView created")
        return mapView
    }

    func updateUIView(_ uiView: MLNMapView, context: Context) {}

    final class Coordinator: NSObject, MLNMapViewDelegate {
        func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
            print("[MapLibre OGL] ✅ mapViewDidFinishLoadingMap")
        }
        func mapViewDidFailLoadingMap(_ mapView: MLNMapView, withError error: Error) {
            print("[MapLibre OGL] ❌ \(error)")
        }
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            print("[MapLibre OGL] ✅ style loaded: \(style.name ?? "?"), layers: \(style.layers.count)")
        }
    }
}
