import Foundation
import Observation
#if canImport(Metal)
import Metal
#endif
#if canImport(OpenGLES)
import OpenGLES
#endif

@Observable
final class DiagnosticsLog {
    var entries: [LogEntry] = []

    var metalAvailable: Bool {
        #if canImport(Metal)
        return MTLCreateSystemDefaultDevice() != nil
        #else
        return false
        #endif
    }

    var openGLES2Available: Bool {
        #if canImport(OpenGLES)
        return EAGLContext(api: .openGLES2) != nil
        #else
        return false
        #endif
    }

    var openGLES3Available: Bool {
        #if canImport(OpenGLES)
        return EAGLContext(api: .openGLES3) != nil
        #else
        return false
        #endif
    }

    func add(_ severity: Severity, _ message: String) {
        entries.append(LogEntry(timestamp: Date(), severity: severity, message: message))
    }

    func exportText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return entries.map { entry in
            "[\(formatter.string(from: entry.timestamp))] \(entry.severity.label) \(entry.message)"
        }.joined(separator: "\n")
    }

    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let severity: Severity
        let message: String
    }

    enum Severity {
        case info, warning, error

        var label: String {
            switch self {
            case .info: "INFO"
            case .warning: "WARN"
            case .error: "ERROR"
            }
        }
    }
}
