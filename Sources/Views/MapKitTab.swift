import SwiftUI
import MapKit

struct MapKitTab: View {
    var body: some View {
        NavigationStack {
            MapKitContainerView()
                .navigationTitle("MapKit")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapKitContainerView: View {
    @State private var mapView: MKMapView?

    private let overviewRegion = MKCoordinateRegion(
        center: TestContent.center,
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    )

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapKitMapView(mapView: $mapView)

            VStack(spacing: 8) {
                Button {
                    mapView?.setRegion(overviewRegion, animated: true)
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
                        var region = map.region
                        region.span.latitudeDelta = max(region.span.latitudeDelta / 2, 0.001)
                        region.span.longitudeDelta = max(region.span.longitudeDelta / 2, 0.001)
                        map.setRegion(region, animated: true)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial)
                    }
                    Divider().frame(width: 44)
                    Button {
                        guard let map = mapView else { return }
                        var region = map.region
                        region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 180)
                        region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 360)
                        map.setRegion(region, animated: true)
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

struct MapKitMapView: UIViewRepresentable {
    @Binding var mapView: MKMapView?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.setRegion(
            MKCoordinateRegion(
                center: TestContent.center,
                span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
            ),
            animated: false
        )
        addPolygonOverlay(to: map)
        print("[MapKit] MKMapView created")
        DispatchQueue.main.async { self.mapView = map }
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    private func addPolygonOverlay(to map: MKMapView) {
        let coords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 45.70, longitude: -122.10),
            CLLocationCoordinate2D(latitude: 45.70, longitude: -121.50),
            CLLocationCoordinate2D(latitude: 45.55, longitude: -121.45),
            CLLocationCoordinate2D(latitude: 45.40, longitude: -121.40),
            CLLocationCoordinate2D(latitude: 45.25, longitude: -121.45),
            CLLocationCoordinate2D(latitude: 45.15, longitude: -121.55),
            CLLocationCoordinate2D(latitude: 45.10, longitude: -121.75),
            CLLocationCoordinate2D(latitude: 45.15, longitude: -121.90),
            CLLocationCoordinate2D(latitude: 45.25, longitude: -122.05),
            CLLocationCoordinate2D(latitude: 45.40, longitude: -122.15),
            CLLocationCoordinate2D(latitude: 45.55, longitude: -122.20),
            CLLocationCoordinate2D(latitude: 45.70, longitude: -122.10),
        ]
        let polygon = MKPolygon(coordinates: coords, count: coords.count)
        polygon.title = "Mt. Hood National Forest"
        map.addOverlay(polygon)

        let summit = MKPointAnnotation()
        summit.coordinate = CLLocationCoordinate2D(latitude: 45.3735, longitude: -121.6960)
        summit.title = "Mt. Hood"
        summit.subtitle = "11,250 ft"
        map.addAnnotation(summit)
        print("[MapKit] polygon + summit annotation added")
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 0.25)
                renderer.strokeColor = UIColor(red: 0, green: 0.39, blue: 0, alpha: 1)
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            print("[MapKit] ✅ mapViewDidFinishLoadingMap")
        }
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            print("[MapKit] ❌ \(error)")
        }
    }
}
