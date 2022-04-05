    import XCTest
    @testable import Visualization

    final class VisualizationTests: XCTestCase {
        func testReadableRange() {
            // Negative start
            var range = ReadableRange(lower: -1.0, upper: 1.0, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(-1.0))
            XCTAssertEqual(range.end, Decimal(1.0))
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.increment, Decimal(0.5))
            // Zero start
            range = ReadableRange(lower: 0.0, upper: 4.0, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0.0))
            XCTAssertEqual(range.end, Decimal(4.0))
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.increment, Decimal(1.0))
            // Positive start rounding
            range = ReadableRange(lower: 0.3, upper: 1.7, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0.0))
            XCTAssertEqual(range.end, Decimal(2.0))
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.increment, Decimal(0.5))
            // Negative start rounding
            range = ReadableRange(lower: -0.3, upper: 2.3, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(-0.5))
            XCTAssertEqual(range.end, Decimal(2.5))
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.increment, Decimal(0.5))
        }
    }
