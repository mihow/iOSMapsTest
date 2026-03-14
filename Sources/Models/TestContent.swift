import Foundation
import CoreLocation

struct TestAnnotation: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum TestContent {
    static let center = CLLocationCoordinate2D(latitude: 45.5150, longitude: -122.6280)
    static let defaultZoom: Double = 15.0
    static let osmTileURL = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"

    static func loadAnnotations() -> [TestAnnotation] {
        guard let url = Bundle.main.url(forResource: "test-annotations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let annotations = try? JSONDecoder().decode([TestAnnotation].self, from: data) else {
            return []
        }
        return annotations
    }

    static func loadPolygonGeoJSON() -> Data? {
        guard let url = Bundle.main.url(forResource: "test-polygon", withExtension: "geojson") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
}
