import SwiftUI

struct DiagnosticsView: View {
    @Environment(DiagnosticsLog.self) private var log

    var body: some View {
        NavigationStack {
            List {
                Section("GPU Capabilities") {
                    LabeledContent("Metal", value: log.metalAvailable ? "✅ available" : "❌ unavailable")
                    LabeledContent("OpenGL ES 2.0", value: log.openGLES2Available ? "✅" : "❌")
                    LabeledContent("OpenGL ES 3.0", value: log.openGLES3Available ? "✅" : "❌")
                }
                Section("Log (\(log.entries.count))") {
                    ForEach(log.entries) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.message)
                                .font(.caption)
                            Text(entry.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Copy") {
                        UIPasteboard.general.string = log.exportText()
                    }
                }
            }
        }
    }
}
