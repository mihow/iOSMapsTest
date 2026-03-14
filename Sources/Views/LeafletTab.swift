import SwiftUI
import WebKit

struct LeafletTab: View {
    var body: some View {
        NavigationStack {
            LeafletContainerView()
                .navigationTitle("Leaflet")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LeafletContainerView: View {
    @State private var webView: WKWebView?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LeafletMapView(webView: $webView)

            VStack(spacing: 8) {
                Button {
                    webView?.evaluateJavaScript("map.setView([45.42, -122.05], 8);", completionHandler: nil)
                } label: {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(spacing: 0) {
                    Button {
                        webView?.evaluateJavaScript("map.zoomIn();", completionHandler: nil)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial)
                    }
                    Divider().frame(width: 44)
                    Button {
                        webView?.evaluateJavaScript("map.zoomOut();", completionHandler: nil)
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

struct LeafletMapView: UIViewRepresentable {
    @Binding var webView: WKWebView?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        if let url = Bundle.main.url(forResource: "leaflet", withExtension: "html") {
            wv.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            print("[Leaflet] loading leaflet.html")
        } else {
            print("[Leaflet] ❌ leaflet.html not found in bundle")
        }
        DispatchQueue.main.async { self.webView = wv }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
