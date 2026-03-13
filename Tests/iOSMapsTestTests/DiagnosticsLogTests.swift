import Foundation
import Testing
@testable import iOSMapsTest

@Suite("DiagnosticsLog Tests")
struct DiagnosticsLogTests {
    @Test("Adding entries appends to log")
    func addEntry() {
        let log = DiagnosticsLog()
        log.add(.info, "Test message")
        #expect(log.entries.count == 1)
        #expect(log.entries[0].message == "Test message")
        #expect(log.entries[0].severity == .info)
    }

    @Test("Entries have timestamps")
    func entryTimestamp() {
        let log = DiagnosticsLog()
        let before = Date()
        log.add(.warning, "Warning")
        let after = Date()
        #expect(log.entries[0].timestamp >= before)
        #expect(log.entries[0].timestamp <= after)
    }

    @Test("Export produces readable text")
    func exportText() {
        let log = DiagnosticsLog()
        log.add(.info, "First")
        log.add(.error, "Second")
        let text = log.exportText()
        #expect(text.contains("INFO"))
        #expect(text.contains("First"))
        #expect(text.contains("ERROR"))
        #expect(text.contains("Second"))
    }

    @Test("Metal availability is detected")
    func metalAvailability() {
        let log = DiagnosticsLog()
        let _ = log.metalAvailable
    }

    @Test("OpenGL ES availability is detected")
    func openGLAvailability() {
        let log = DiagnosticsLog()
        let _ = log.openGLES2Available
        let _ = log.openGLES3Available
    }
}
