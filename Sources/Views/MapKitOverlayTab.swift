import SwiftUI
import MapKit

struct MapKitOverlayTab: View {
    var body: some View {
        NavigationStack {
            MapKitOverlayView()
                .navigationTitle("MK+Overlay")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapKitOverlayView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        let overlay = MKTileOverlay(urlTemplate: TestContent.osmTileURL)
        overlay.canReplaceMapContent = true
        map.addOverlay(overlay, level: .aboveLabels)
        map.setRegion(
            MKCoordinateRegion(
                center: TestContent.center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ),
            animated: false
        )
        print("[MK+Overlay] MKMapView + MKTileOverlay created")
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tile = overlay as? MKTileOverlay {
                let renderer = MKTileOverlayRenderer(tileOverlay: tile)
                print("[MK+Overlay] ✅ tile renderer created")
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            print("[MK+Overlay] mapViewDidFinishLoadingMap")
        }
    }
}
