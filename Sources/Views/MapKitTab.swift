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
        print("[MapKit] MKMapView created")
        DispatchQueue.main.async { self.mapView = map }
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
