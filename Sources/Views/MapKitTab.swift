import SwiftUI
import MapKit

struct MapKitTab: View {
    var body: some View {
        NavigationStack {
            MapKitMapView()
                .navigationTitle("MapKit")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapKitMapView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.setRegion(
            MKCoordinateRegion(
                center: TestContent.center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ),
            animated: false
        )
        print("[MapKit] MKMapView created")
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            print("[MapKit] ✅ mapViewDidFinishLoadingMap")
        }
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            print("[MapKit] ❌ \(error)")
        }
    }
}
