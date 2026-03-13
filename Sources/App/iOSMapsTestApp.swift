import SwiftUI

@main
struct iOSMapsTestApp: App {
    @State private var diagnostics = DiagnosticsLog()

    var body: some Scene {
        WindowGroup {
            TabView {
                MapKitTab()
                    .tabItem { Label("MapKit", systemImage: "map") }
                MapKitOverlayTab()
                    .tabItem { Label("MK+Overlay", systemImage: "square.grid.3x3") }
                MapLibreMetalTab()
                    .tabItem { Label("ML Metal", systemImage: "cpu") }
                LeafletTab()
                    .tabItem { Label("Leaflet", systemImage: "globe") }
            }
            .environment(diagnostics)
            .overlay(alignment: .bottom) {
                DiagnosticsOverlay()
            }
        }
    }
}

struct DiagnosticsOverlay: View {
    @Environment(DiagnosticsLog.self) private var log
    @State private var showDiagnostics = false

    var body: some View {
        VStack {
            Spacer()
            Button {
                showDiagnostics.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "stethoscope")
                    Text("\(log.entries.count)")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .padding(.bottom, 60)
            .sheet(isPresented: $showDiagnostics) {
                DiagnosticsView()
            }
        }
    }
}
