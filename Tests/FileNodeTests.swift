import XCTest
@testable import ItsypadCore

final class FileNodeTests: XCTestCase {

    // MARK: - Filtering

    func testHiddenFilesExcluded() {
        XCTAssertFalse(FileNode.shouldInclude(".hidden", isHidden: true))
    }

    func testDSStoreExcluded() {
        XCTAssertFalse(FileNode.shouldInclude(".DS_Store", isHidden: false))
    }

    func testGitExcluded() {
        XCTAssertFalse(FileNode.shouldInclude(".git", isHidden: false))
    }

    func testNodeModulesExcluded() {
        XCTAssertFalse(FileNode.shouldInclude("node_modules", isHidden: false))
    }

    func testNormalFileIncluded() {
        XCTAssertTrue(FileNode.shouldInclude("readme.md", isHidden: false))
    }

    func testNormalFolderIncluded() {
        XCTAssertTrue(FileNode.shouldInclude("src", isHidden: false))
    }

    // MARK: - Sorting

    func testDirectoriesBeforeFiles() {
        let nodes = [
            FileNode(url: URL(fileURLWithPath: "/b.txt"), name: "b.txt", isDirectory: false, children: nil),
            FileNode(url: URL(fileURLWithPath: "/a"), name: "a", isDirectory: true, children: []),
        ]
        let sorted = FileNode.sorted(nodes)
        XCTAssertTrue(sorted[0].isDirectory)
        XCTAssertFalse(sorted[1].isDirectory)
    }

    func testAlphabeticalWithinSameType() {
        let nodes = [
            FileNode(url: URL(fileURLWithPath: "/c.txt"), name: "c.txt", isDirectory: false, children: nil),
            FileNode(url: URL(fileURLWithPath: "/a.txt"), name: "a.txt", isDirectory: false, children: nil),
            FileNode(url: URL(fileURLWithPath: "/b.txt"), name: "b.txt", isDirectory: false, children: nil),
        ]
        let sorted = FileNode.sorted(nodes)
        XCTAssertEqual(sorted.map(\.name), ["a.txt", "b.txt", "c.txt"])
    }

    func testCaseInsensitiveSorting() {
        let nodes = [
            FileNode(url: URL(fileURLWithPath: "/Zebra"), name: "Zebra", isDirectory: true, children: []),
            FileNode(url: URL(fileURLWithPath: "/apple"), name: "apple", isDirectory: true, children: []),
        ]
        let sorted = FileNode.sorted(nodes)
        XCTAssertEqual(sorted.map(\.name), ["apple", "Zebra"])
    }

    func testFolderSearchIncludesNestedFilesAndRespectsSidebarExclusions() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        for directory in ["notes", "node_modules", ".hidden"] {
            try FileManager.default.createDirectory(at: root.appendingPathComponent(directory), withIntermediateDirectories: true)
        }
        for path in ["notes/Todo.md", "notes/other.txt", "node_modules/todo.txt", ".hidden/todo.txt", "Todo.txt"] {
            try Data().write(to: root.appendingPathComponent(path))
        }
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("linked-notes"), withDestinationURL: root.appendingPathComponent("notes"))

        let files = try FolderFileSearch.files(in: root)
        XCTAssertEqual(Set(files.map { FolderFileSearch.relativePath(of: $0, in: root) }), Set(["notes/Todo.md", "notes/other.txt", "Todo.txt"]))
        XCTAssertEqual(FolderFileSearch.matches(query: " TODO ", files: files, root: root).count, 2)
        XCTAssertEqual(FolderFileSearch.matches(query: "notes/other", files: files, root: root).map(\.lastPathComponent), ["other.txt"])
        XCTAssertTrue(FolderFileSearch.matches(query: "  ", files: files, root: root).isEmpty)
    }

    func testFolderSearchReportsMissingRoot() {
        let missing = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        XCTAssertThrowsError(try FolderFileSearch.files(in: missing))
    }
}
