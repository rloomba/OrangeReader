import XCTest
@testable import Orange_Reader

final class OrangeReaderTests: XCTestCase {
    func testRelativeTime() {
        let now = Date().timeIntervalSince1970
        let str = Formatters.relativeTime(from: now - 90)
        XCTAssertNotNil(str)
    }
}
