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
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["-1.0", "-0.5", "0.0", "0.5"])

            // Zero start
            range = ReadableRange(lower: 0.0, upper: 4.0, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0.0))
            XCTAssertEqual(range.end, Decimal(4.0))
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.increment, Decimal(1.0))
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["0", "1", "2", "3"])

            // Positive start rounding
            range = ReadableRange(lower: 0.3, upper: 1.7, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0.0))
            XCTAssertEqual(range.end, Decimal(2.0))
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.increment, Decimal(0.5))
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["0.0", "0.5", "1.0", "1.5"])

            // Positive start above an increment
            range = ReadableRange(lower: 1.3, upper: 4.0, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(1.0))
            XCTAssertEqual(range.end, Decimal(4.0))
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.increment, Decimal(0.5))
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["1.0", "1.5", "2.0", "2.5", "3.0", "3.5"])

            // Negative start rounding
            range = ReadableRange(lower: -0.3, upper: 2.3, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(-0.5))
            XCTAssertEqual(range.end, Decimal(2.5))
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.increment, Decimal(0.5))
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["-0.5", "0.0", "0.5", "1.0", "1.5", "2.0"])

            // Factor out a power of 10e3
            range = ReadableRange(lower: 0, upper: 50000, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0))
            XCTAssertEqual(range.end, Decimal(50000))
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.increment, Decimal(10000))
            XCTAssertEqual(range.labelFactor, 1000)
            XCTAssertEqual(range.labels, ["0", "10", "20", "30", "40"])

            // Negative values. Factor out a power of 10e3.
            range = ReadableRange(lower: -100000, upper: -50000, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(-100000))
            XCTAssertEqual(range.end, Decimal(-50000))
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.increment, Decimal(10000))
            XCTAssertEqual(range.labelFactor, 1000)
            XCTAssertEqual(range.labels, ["-100", "-90", "-80", "-70", "-60"])

            // Start below lower. Factor out a power of 10e3.
            range = ReadableRange(lower: 100000, upper: 900000, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0))
            XCTAssertEqual(range.end, Decimal(1000000))
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.increment, Decimal(200000))
            XCTAssertEqual(range.labelFactor, 1000)
            XCTAssertEqual(range.labels, ["0", "200", "400", "600", "800"])

            // Start above 0. Factor out a power of 10e3.
            range = ReadableRange(lower: 100000, upper: 500000, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(100000))
            XCTAssertEqual(range.end, Decimal(500000))
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.increment, Decimal(100000))
            XCTAssertEqual(range.labelFactor, 1000)
            XCTAssertEqual(range.labels, ["100", "200", "300", "400"])

            // TODO: Subtract a common offset. Leave last 10e3.
            // TODO: Based around increment order?
            // TODO: Subtracting an offset will change the data plot.
//            range = ReadableRange(lower: 123456, upper: 123461, count: [4, 5, 6])
//            XCTAssertEqual(range.labels, ["456", "457", "458", "459", "460"])

//            range = ReadableRange(lower: 0.123456, upper: 0.123461, count: [4, 5, 6])
//            XCTAssertEqual(range.labels, ["456", "457", "458", "459", "460"])

            range = ReadableRange(lower: 0.00001, upper: 0.00005, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0.00001))
            XCTAssertEqual(range.end, Decimal(0.00005))
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.increment, Decimal(0.00001))
            XCTAssertEqual(range.labelFactor, 0.000001)
            XCTAssertEqual(range.labels, ["10", "20", "30", "40"])

            range = ReadableRange(lower: 0.001, upper: 0.012, count: [4, 5, 6])
            XCTAssertEqual(range.start, Decimal(0.0))
            XCTAssertEqual(range.end, Decimal(0.012))
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.increment, Decimal(0.002))
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["0.000", "0.002", "0.004", "0.006", "0.008", "0.010"])
        }
    }
