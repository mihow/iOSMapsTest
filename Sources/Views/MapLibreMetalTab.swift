import SwiftUI
import MapLibre

struct MapLibreMetalTab: View {
    var body: some View {
        NavigationStack {
            MapLibreOGLContainerView()
                .navigationTitle("MapLibre GL")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapLibreOGLContainerView: View {
    @State private var mapView: MLNMapView?

    private let overviewCenter = CLLocationCoordinate2D(latitude: 45.42, longitude: -122.05)
    private let overviewZoom: Double = 8

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
            print("[MapLibre] loading local style: \(localURL)")
        } else {
            styleURL = URL(string: "https://demotiles.maplibre.org/style.json")!
            print("[MapLibre] ⚠️ local style not found, falling back to demo tiles")
        }

        let map = MLNMapView(frame: .zero, styleURL: styleURL)
        map.delegate = context.coordinator
        map.setCenter(
            CLLocationCoordinate2D(latitude: 45.42, longitude: -122.05),
            zoomLevel: 8,
            animated: false
        )
        DispatchQueue.main.async { self.mapView = map }
        return map
    }

    func updateUIView(_ uiView: MLNMapView, context: Context) {}

    final class Coordinator: NSObject, MLNMapViewDelegate {
        func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
            print("[MapLibre] ✅ map loaded")
        }
        func mapViewDidFailLoadingMap(_ mapView: MLNMapView, withError error: Error) {
            print("[MapLibre] ❌ \(error)")
        }
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            print("[MapLibre] ✅ style loaded, adding polygon overlay")
            addPolygonOverlay(to: style)
        }

        private func addPolygonOverlay(to style: MLNStyle) {
            guard let url = Bundle.main.url(forResource: "test-polygon", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url),
                  let shape = try? MLNShape(data: data, encoding: String.Encoding.utf8.rawValue) else {
                print("[MapLibre] ⚠️ could not load test-polygon.geojson")
                return
            }

            let source = MLNShapeSource(identifier: "mt-hood-source", shape: shape, options: nil)
            style.addSource(source)

            // Fill layer
            let fill = MLNFillStyleLayer(identifier: "mt-hood-fill", source: source)
            fill.fillColor = NSExpression(forConstantValue: UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 1))
            fill.fillOpacity = NSExpression(forConstantValue: 0.25)
            style.addLayer(fill)

            // Stroke layer
            let line = MLNLineStyleLayer(identifier: "mt-hood-line", source: source)
            line.lineColor = NSExpression(forConstantValue: UIColor(red: 0, green: 0.39, blue: 0, alpha: 1))
            line.lineWidth = NSExpression(forConstantValue: 2)
            style.addLayer(line)

            // Point annotation for summit
            let point = MLNCircleStyleLayer(identifier: "mt-hood-point", source: source)
            point.circleRadius = NSExpression(forConstantValue: 6)
            point.circleColor = NSExpression(forConstantValue: UIColor.red)
            point.circleStrokeWidth = NSExpression(forConstantValue: 2)
            point.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
            point.predicate = NSPredicate(format: "$geometryType = %@", "Point")
            style.addLayer(point)

            print("[MapLibre] ✅ polygon + summit marker added")
        }
    }
}
