    import XCTest
    @testable import Visualization

    final class VisualizationTests: XCTestCase {
        func testReadableRange() {
            // Negative start
            var range = ReadableRange(lower: -1.0, upper: 1.0, count: [4, 5, 6])
            XCTAssertEqual(range.start, -1.0)
            XCTAssertEqual(range.end, 1.0)
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["-1.0", "-0.5", "0.0", "0.5"])

            // Zero start
            range = ReadableRange(lower: 0.0, upper: 4.0, count: [4, 5, 6])
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.end, 4.0)
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["0", "1", "2", "3"])

            // Positive start rounding
            range = ReadableRange(lower: 0.3, upper: 1.7, count: [4, 5, 6])
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.end, 2.0)
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["0.0", "0.5", "1.0", "1.5"])

            // Positive start above an increment
            range = ReadableRange(lower: 1.3, upper: 4.0, count: [4, 5, 6])
            XCTAssertEqual(range.start, 1.0)
            XCTAssertEqual(range.end, 4.0)
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["1.0", "1.5", "2.0", "2.5", "3.0", "3.5"])

            // Negative start rounding
            range = ReadableRange(lower: -0.3, upper: 2.3, count: [4, 5, 6])
            XCTAssertEqual(range.start, -0.5)
            XCTAssertEqual(range.end, 2.5)
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["-0.5", "0.0", "0.5", "1.0", "1.5", "2.0"])

            // Factor out a power of 10e3
            range = ReadableRange(lower: 0, upper: 50000, count: [4, 5, 6])
            XCTAssertEqual(range.start, 0)
            XCTAssertEqual(range.end, 50000)
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.labelFactor, 1000)
            XCTAssertEqual(range.labels, ["0", "10", "20", "30", "40"])

            // Negative values. Factor out a power of 10e3.
            range = ReadableRange(lower: -100000, upper: -50000, count: [4, 5, 6])
            XCTAssertEqual(range.start, -100000)
            XCTAssertEqual(range.end, -50000)
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.labelFactor, 1000)
            XCTAssertEqual(range.labels, ["-100", "-90", "-80", "-70", "-60"])

            // Start below lower. Factor out a power of 10e3.
            range = ReadableRange(lower: 100000, upper: 900000, count: [4, 5, 6])
            XCTAssertEqual(range.start, 0)
            XCTAssertEqual(range.end, 1000000)
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.labelFactor, 1000)
            XCTAssertEqual(range.labels, ["0", "200", "400", "600", "800"])

            // Start above 0. Factor out a power of 10e3.
            range = ReadableRange(lower: 100000, upper: 500000, count: [4, 5, 6])
            XCTAssertEqual(range.start, 100000)
            XCTAssertEqual(range.end, 500000)
            XCTAssertEqual(range.count, 4)
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
            XCTAssertEqual(range.start, 0.00001)
            XCTAssertEqual(range.end, 0.00005)
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.labelFactor, 0.000001)
            XCTAssertEqual(range.labels, ["10", "20", "30", "40"])

            range = ReadableRange(lower: 0.001, upper: 0.012, count: [4, 5, 6])
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.end, 0.012)
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["0.000", "0.002", "0.004", "0.006", "0.008", "0.010"])
        }

        func testReadableDurationRange() {
            // Trivial example
            var range = ReadableDurationRange(lower: Measurement(value: 0.0, unit: UnitDuration.seconds),
                                              upper: Measurement(value: 12.0, unit: UnitDuration.seconds))
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.count, 3)
            XCTAssertEqual(range.labels, ["0", "5", "10"])

            // Lower is rounded down to start at 0
            range = ReadableDurationRange(lower: Measurement(value: 1.0, unit: UnitDuration.seconds),
                                          upper: Measurement(value: 12.0, unit: UnitDuration.seconds))
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.count, 3)
            XCTAssertEqual(range.labels, ["0", "5", "10"])

            // Start is greater than zero
            range = ReadableDurationRange(lower: Measurement(value: 4.0, unit: UnitDuration.seconds),
                                          upper: Measurement(value: 12.0, unit: UnitDuration.seconds))
            XCTAssertEqual(range.start, 4.0)
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.labels, ["4", "6", "8", "10"])

            // A small range of hours uses minutes
            range = ReadableDurationRange(lower: Measurement(value: 0.0, unit: UnitDuration.hours),
                                          upper: Measurement(value: 1.75, unit: UnitDuration.hours))
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.labels, ["0", "30", "60", "90"])

            // A large range of seconds uses minutes
            range = ReadableDurationRange(lower: Measurement(value: 0.0, unit: UnitDuration.seconds),
                                          upper: Measurement(value: 300.0, unit: UnitDuration.seconds))
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.end, 300.0)
            XCTAssertEqual(range.labels, ["0", "1", "2", "3", "4"])

            // A large range of hours uses its unique factors
            range = ReadableDurationRange(lower: Measurement(value: 0.0, unit: UnitDuration.hours),
                                          upper: Measurement(value: 60.0, unit: UnitDuration.hours))
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.count, 5)
            XCTAssertEqual(range.labels, ["0", "12", "24", "36", "48"])

            // Milliseconds and their base 10 nature
            range = ReadableDurationRange(lower: Measurement(value: 0.0, unit: UnitDuration.seconds),
                                          upper: Measurement(value: 2.0, unit: UnitDuration.seconds))
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.count, 4)
            XCTAssertEqual(range.end, 2.0)
            XCTAssertEqual(range.labels, ["0", "500", "1000", "1500"])
        }
    }
