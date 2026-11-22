import XCTest
import CloudKit
@testable import ItsypadCore

final class CloudSyncEngineTests: XCTestCase {

    func testCloudKitRequiresServiceAndExpectedContainerEntitlements() {
        let container = "iCloud.com.nickustinov.itsypad"
        XCTAssertTrue(CloudSyncEngine.supportsCloudKit(services: ["CloudKit"], containers: [container]))
        XCTAssertFalse(CloudSyncEngine.supportsCloudKit(services: nil, containers: [container]))
        XCTAssertFalse(CloudSyncEngine.supportsCloudKit(services: ["CloudKit"], containers: nil))
        XCTAssertFalse(CloudSyncEngine.supportsCloudKit(services: ["CloudKit"], containers: ["iCloud.example.other"]))
        XCTAssertFalse(CloudSyncEngine.supportsCloudKit(services: ["CloudKit-Anonymous"], containers: [container]))
    }

    func testStartingWithoutEntitlementsDoesNotCreateCloudKitContainer() throws {
        try XCTSkipIf(CloudSyncEngine.isCloudKitAvailable, "This test requires an unsigned or unentitled test process")
        try XCTSkipIf(ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil, "The test-host guard would bypass the entitlement check")
        CloudSyncEngine.shared.start()
    }

    // MARK: - CloudTabRecord

    func testCloudTabRecordHoldsAllFields() {
        let id = UUID()
        let now = Date()
        let record = CloudTabRecord(
            id: id,
            name: "Test",
            content: "hello",
            language: "swift",
            languageLocked: true,
            lastModified: now
        )
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.name, "Test")
        XCTAssertEqual(record.content, "hello")
        XCTAssertEqual(record.language, "swift")
        XCTAssertTrue(record.languageLocked)
        XCTAssertEqual(record.lastModified, now)
    }

    // MARK: - CloudClipboardRecord

    func testCloudClipboardRecordHoldsAllFields() {
        let id = UUID()
        let now = Date()
        let record = CloudClipboardRecord(id: id, text: "copied text", timestamp: now)
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.text, "copied text")
        XCTAssertEqual(record.timestamp, now)
    }

    // MARK: - RecordType raw values

    func testRecordTypeRawValues() {
        XCTAssertEqual(CloudSyncEngine.RecordType.scratchTab.rawValue, "ScratchTab")
        XCTAssertEqual(CloudSyncEngine.RecordType.clipboardEntry.rawValue, "ClipboardEntry")
    }
}
