import SwiftUI

@main
struct iOSMapsTestApp: App {
    @State private var diagnostics = DiagnosticsLog()

    var body: some Scene {
        WindowGroup {
            ContentView(diagnostics: diagnostics)
        }
    }
}

struct ContentView: View {
    let diagnostics: DiagnosticsLog
    @State private var showDiagnostics = false
    @State private var selectedTab = 2  // Start on MapLibre GL tab

    var body: some View {
        TabView(selection: $selectedTab) {
            MapKitTab()
                .tabItem { Label("MapKit", systemImage: "map") }
                .tag(0)
            MapKitOverlayTab()
                .tabItem { Label("MK+Overlay", systemImage: "square.grid.3x3") }
                .tag(1)
            MapLibreMetalTab()
                .tabItem { Label("MapLibre GL", systemImage: "cpu") }
                .tag(2)
            LeafletTab()
                .tabItem { Label("Leaflet", systemImage: "globe") }
                .tag(3)
        }
        .environment(diagnostics)
        .overlay(alignment: .bottom) {
            VStack {
                Spacer()
                Button {
                    showDiagnostics.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "stethoscope")
                        Text("\(diagnostics.entries.count)")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showDiagnostics) {
            DiagnosticsView()
                .environment(diagnostics)
        }
        .onAppear {
            print("=== GPU CAPABILITIES ===")
            print("Metal: \(diagnostics.metalAvailable)")
            print("OpenGL ES 2.0: \(diagnostics.openGLES2Available)")
            print("OpenGL ES 3.0: \(diagnostics.openGLES3Available)")
            print("========================")
        }
    }
}
