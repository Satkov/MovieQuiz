import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        // When
        let value = array[safe: 3]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 4)
    }

    func testGetValueOutOfRange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        // When
        let value = array[safe: 5]
        // Then
        XCTAssertNil(value)
    }
}
