    import XCTest
    @testable import Visualization

    final class VisualizationTests: XCTestCase {
        static func assertAlmostEqual(_ expression1: Double, _ expression2: Double, precision: Double = 0.001) {
            XCTAssertLessThan(abs(expression1 - expression2) / expression1,
                              precision,
                              "\(expression1) is not almost equal to \(expression2) within \(100 * precision)%")
        }

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
            XCTAssertEqual(range.integerDigits, 2)
            XCTAssertEqual(range.fractionalDigits, 0)

            range = ReadableRange(lower: 0.001, upper: 0.012, count: [4, 5, 6])
            XCTAssertEqual(range.start, 0.0)
            XCTAssertEqual(range.end, 0.012)
            XCTAssertEqual(range.count, 6)
            XCTAssertEqual(range.labelFactor, 1)
            XCTAssertEqual(range.labels, ["0.000", "0.002", "0.004", "0.006", "0.008", "0.010"])
            XCTAssertEqual(range.integerDigits, 1)
            XCTAssertEqual(range.fractionalDigits, 3)

            range = ReadableRange(lower: 1.380, upper: 1.384, count: [4])
            XCTAssertEqual(range.labels, ["1.380", "1.381", "1.382", "1.383"])
            XCTAssertEqual(range.integerDigits, 1)
            XCTAssertEqual(range.fractionalDigits, 3)
            let lower: CGFloat = 1.380 + (1.384 - 1.380) / 2 - (1.384 - 1.380) / 2
            let upper: CGFloat = 1.380 + (1.384 - 1.380) / 2 + (1.384 - 1.380) / 2
            XCTAssertEqual(range.labelsForRange(lower: Decimal(lower), upper: Decimal(upper)), ["1.380", "1.381", "1.382", "1.383"])

            range = ReadableRange(lower: 0, upper: 100, count: [5])
            XCTAssertEqual(range.labelsForRange(lower: 0, upper: 100), ["0", "20", "40", "60", "80"])
            XCTAssertEqual(range.labelsForRange(lower: 40, upper: 60), ["40", "44", "48", "52", "56"])
            XCTAssertEqual(range.labelsForRange(lower: 49, upper: 52), ["49.0", "49.6", "50.2", "50.8", "51.4"])
        }

        func testOrder() {
            var order = ReadableRange.order(0.84)
            XCTAssertEqual(order, -1)
            order = ReadableRange.order(0.84049999999 - 0.84)
            XCTAssertEqual(order, -4)
            order = ReadableRange.order(1000000)
            XCTAssertEqual(order, 7)
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

        func testReadablePaceRange() {
            // 5:33 per kilometer == 3.0 m/s
            // 3:20 per kilometer == 5.0 m/s
            var range = ReadablePaceRange(lower: Measurement(value: 5 + 33 / 60.0, unit: UnitPace.minutesPerKilometer),
                                          upper: Measurement(value: 3 + 20 / 60.0, unit: UnitPace.minutesPerKilometer))
            XCTAssertEqual(range!.start, Measurement(value: 6, unit: UnitPace.minutesPerKilometer).value)
            XCTAssertEqual(range!.end, Measurement(value: 3, unit: UnitPace.minutesPerKilometer).value)
            XCTAssertEqual(range!.labels, ["06:00", "05:00", "04:00"])

            // 5:33 per kilometer == 8:56 min/mile == 3.0 m/s
            // 3:20 per kilometer == 5:22 min/mile == 5.0 m/s
            range = ReadablePaceRange(lower: Measurement(value: 5 + 33 / 60.0, unit: UnitPace.minutesPerKilometer),
                                      upper: Measurement(value: 3 + 20 / 60.0, unit: UnitPace.minutesPerKilometer), labelUnit: UnitPace.minutesPerMile)
            XCTAssertEqual(range!.start, Measurement(value: 9, unit: UnitPace.minutesPerMile).value)
            XCTAssertEqual(range!.end, Measurement(value: 5, unit: UnitPace.minutesPerMile).value)
            XCTAssertEqual(range!.labels, ["09:00", "08:00", "07:00", "06:00"])

            // 3:20 per kilometer == 80 s/400m == 5.0 m/s
            // 2:22 per kilometer == 57 s/400m == 7.0 m/s
            range = ReadablePaceRange(lower: Measurement(value: 3 + 20 / 60.0, unit: UnitPace.minutesPerKilometer),
                                      upper: Measurement(value: 2 + 22 / 60.0, unit: UnitPace.minutesPerKilometer), labelUnit: UnitPace.minutesPer400)
            XCTAssertEqual(range!.start, Measurement(value: 1.5, unit: UnitPace.minutesPer400).value)
            XCTAssertEqual(range!.end, Measurement(value: 50.0 / 60, unit: UnitPace.minutesPer400).value)
            XCTAssertEqual(range!.labels, ["90", "80", "70", "60"])

            // 5:33 per kilometer == 3:54:25 hours/marathon == 3.0 m/s
            // 3:20 per kilometer == 2:20:39 hours/marathon == 5.0 m/s
            range = ReadablePaceRange(lower: Measurement(value: 5 + 33 / 60.0, unit: UnitPace.minutesPerKilometer),
                                      upper: Measurement(value: 3 + 20 / 60.0, unit: UnitPace.minutesPerKilometer), labelUnit: UnitPace.minutesPerMarathon)
            XCTAssertEqual(range!.start, Measurement(value: 4 * 60, unit: UnitPace.minutesPerMarathon).value)
            XCTAssertEqual(range!.end, Measurement(value: 2 * 60, unit: UnitPace.minutesPerMarathon).value)
            XCTAssertEqual(range!.labels, ["04:00", "03:30", "03:00", "02:30"])

            // ∞ per kilometer == ∞ min/mile == 0.0 m/s
            // 3:20 per kilometer == 5:22 min/mile == 5.0 m/s
            range = ReadablePaceRange(lower: Measurement(value: Double.infinity, unit: UnitPace.minutesPerKilometer),
                                      upper: Measurement(value: 3 + 20 / 60.0, unit: UnitPace.minutesPerKilometer), labelUnit: UnitPace.minutesPerMile)
            XCTAssertNil(range)
        }

        func testUnitPace() {
            // 1000 m / 3 m/s / 60s = 5.55 == 5:33 per kilometer
            XCTAssertEqual(UnitPace.fromSpeed(Measurement(value: 3.0, unit: UnitSpeed.metersPerSecond)),
                           Measurement(value: 1000 / 3.0 / 60, unit: UnitPace.minutesPerKilometer))
            // 1000 m / 3 m/s / 60s * 1.609344 km/mile = 8.94 == 8:56 per mile
            XCTAssertEqual(UnitPace.fromSpeed(Measurement(value: 3.0, unit: UnitSpeed.metersPerSecond))
                .converted(to: UnitPace.minutesPerMile),
                           Measurement(value: 1000 / 3.0 / 60 * 1.609344, unit: UnitPace.minutesPerMile))
            // 1000 m / 5 m/s / 60s = 3.333 == 3:20 per kilometer
            XCTAssertEqual(UnitPace.fromSpeed(Measurement(value: 5.0, unit: UnitSpeed.metersPerSecond)),
                           Measurement(value: 1000 / 5.0 / 60, unit: UnitPace.minutesPerKilometer))
            // 1000 m / 5 m/s / 60s * 1.609344 km/mile = 5.364 == 5:22 per mile
            XCTAssertEqual(UnitPace.fromSpeed(Measurement(value: 5.0, unit: UnitSpeed.metersPerSecond))
                .converted(to: UnitPace.minutesPerMile),
                           Measurement(value: 1000 / 5.0 / 60 * 1.609344, unit: UnitPace.minutesPerMile))
            // Calculate a pace of infinity when speed is zero
            XCTAssertEqual(UnitPace.fromSpeed(Measurement(value: 0.0, unit: UnitSpeed.metersPerSecond)),
                           Measurement(value: Double.infinity, unit: .minutesPerKilometer))
            // Convert a pace of infinity from a speed of zero
            XCTAssertEqual(UnitPace.fromSpeed(Measurement(value: 0.0, unit: UnitSpeed.metersPerSecond)).converted(to: .minutesPerMile),
                           Measurement(value: Double.infinity, unit: .minutesPerMile))
            // Calculate a speed of zero when pace is infinity
            XCTAssertEqual(UnitPace.toSpeed(Measurement(value: .infinity, unit: .minutesPerKilometer)),
                           Measurement(value: 0.0, unit: .metersPerSecond))
            // Convert a speed of zero from pace of infinity
            XCTAssertEqual(UnitPace.toSpeed(Measurement(value: .infinity, unit: .minutesPerKilometer)).converted(to: .kilometersPerHour),
                           Measurement(value: 0.0, unit: .metersPerSecond))
        }

        func testGridlines() {
            var (major, minor) = GridLineMajorMinorView.gridLinePositions(lower: 20.0, upper: 72.0)
            XCTAssertEqual(major, [10.0 / 52.0, 20.0 / 52.0, 30.0 / 52.0, 40.0 / 52.0, 50.0 / 52.0])
            var expectedMinor = [10 / 52.0 - 2 / 52, 10 / 52.0 - 4 / 52, 10 / 52.0 - 6 / 52, 10 / 52.0 - 8 / 52,
                                 20 / 52.0 - 2 / 52, 20 / 52.0 - 4 / 52, 20 / 52.0 - 6 / 52, 20 / 52.0 - 8 / 52,
                                 30 / 52.0 - 2 / 52, 30 / 52.0 - 4 / 52, 30 / 52.0 - 6 / 52, 30 / 52.0 - 8 / 52,
                                 40 / 52.0 - 2 / 52, 40 / 52.0 - 4 / 52, 40 / 52.0 - 6 / 52, 40 / 52.0 - 8 / 52,
                                 50 / 52.0 - 2 / 52, 50 / 52.0 - 4 / 52, 50 / 52.0 - 6 / 52, 50 / 52.0 - 8 / 52]
            for (expected, value) in zip(expectedMinor, minor) {
                VisualizationTests.assertAlmostEqual(expected, value)
            }

            (major, minor) = GridLineMajorMinorView.gridLinePositions(lower: 0.0, upper: 100.0)
            XCTAssertEqual(major, [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9])
            expectedMinor = []
            for (expected, value) in zip(expectedMinor, minor) {
                XCTAssertEqual(expected, value)
            }

            (major, minor) = GridLineMajorMinorView.gridLinePositions(lower: -5.0, upper: 95.0)
            XCTAssertEqual(major, [0.05])
            XCTAssertEqual(minor, [0.85, 0.65, 0.45, 0.25])
        }
    }
