import SwiftUI
import WebKit

struct LeafletTab: View {
    var body: some View {
        NavigationStack {
            LeafletMapView()
                .navigationTitle("Leaflet")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LeafletMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        if let url = Bundle.main.url(forResource: "leaflet", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            print("[Leaflet] loading leaflet.html")
        } else {
            print("[Leaflet] ❌ leaflet.html not found in bundle")
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
