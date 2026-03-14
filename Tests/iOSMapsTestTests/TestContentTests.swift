import Testing
@testable import iOSMapsTest

@Suite("TestContent Tests")
struct TestContentTests {
    @Test("Load annotations returns 5 items")
    func loadAnnotations() {
        let annotations = TestContent.loadAnnotations()
        #expect(annotations.count == 5)
        #expect(annotations[0].title == "Western Tiger Swallowtail")
        #expect(annotations[0].latitude == 45.5135)
    }

    @Test("Load polygon GeoJSON returns data")
    func loadPolygon() {
        let data = TestContent.loadPolygonGeoJSON()
        #expect(data != nil)
        let str = String(data: data!, encoding: .utf8)!
        #expect(str.contains("Mt. Hood"))
    }

    @Test("Center coordinate is Portland")
    func centerCoordinate() {
        #expect(TestContent.center.latitude == 45.5150)
        #expect(TestContent.center.longitude == -122.6280)
    }

    @Test("OSM tile URL is valid")
    func tileURL() {
        #expect(TestContent.osmTileURL.contains("openstreetmap.org"))
    }
}
