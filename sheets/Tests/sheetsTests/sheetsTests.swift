import XCTest
@testable import sheets

final class sheetsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(sheets().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
