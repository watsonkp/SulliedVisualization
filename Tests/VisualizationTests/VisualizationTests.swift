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

        func testReadablePaceRange() {
            // 1000 m / 3.0 m/s / 60 s/min = 5.55 == 5:33 per kilometer
            // 1000 m / 5.0 m/s / 60 s/min = 3.33 == 3:20 per kilometer
            var range = ReadablePaceRange(lower: Measurement(value: 3.0, unit: UnitSpeed.metersPerSecond),
                                          upper: Measurement(value: 5.0, unit: UnitSpeed.metersPerSecond))
            XCTAssertEqual(range!.start, Measurement(value: 1000 / (6 * 60.0), unit: UnitSpeed.metersPerSecond).value)
            XCTAssertEqual(range!.end, Measurement(value: 1000 / (3 * 60.0), unit: UnitSpeed.metersPerSecond).value)
            XCTAssertEqual(range!.labels, ["06:00", "05:00", "04:00"])

            // 1609.344 m / 3.0 m/s / 60 s/min = 8.941 == 8:56 per mile
            // 1609.344 m / 5.0 m/s / 60 s/min = 5.364 == 5:22 per mile
            range = ReadablePaceRange(lower: Measurement(value: 3.0, unit: UnitSpeed.metersPerSecond),
                                      upper: Measurement(value: 5.0, unit: UnitSpeed.metersPerSecond), labelUnit: UnitPace.minutesPerMile)
            VisualizationTests.assertAlmostEqual(range!.start, Measurement(value: 1609.344 / (9 * 60), unit: UnitSpeed.metersPerSecond).value)
            XCTAssertEqual(range!.end, Measurement(value: 1609.344 / (5 * 60), unit: UnitSpeed.metersPerSecond).value)
            XCTAssertEqual(range!.labels, ["09:00", "08:00", "07:00", "06:00"])

            // 400 m / 5.0 m/s = 80 per 400 m
            // 400 m / 7.0 m/s = 57 per 400 m
            range = ReadablePaceRange(lower: Measurement(value: 5.0, unit: UnitSpeed.metersPerSecond),
                                      upper: Measurement(value: 7.0, unit: UnitSpeed.metersPerSecond), labelUnit: UnitPace.minutesPer400)
            XCTAssertEqual(range!.start, Measurement(value: 400 / 90.0, unit: UnitSpeed.metersPerSecond).value)
            VisualizationTests.assertAlmostEqual(range!.end, Measurement(value: 400 / 50.0, unit: UnitSpeed.metersPerSecond).value)
            XCTAssertEqual(range!.labels, ["90", "80", "70", "60"])

            // 42195 m / 3 m/s / 3600 s/hr = 3.91 == 3:56 per marathon
            // 42195 m / 5 m/s / 3600 s/hr = 2.34 == 2:21 per marathon
            range = ReadablePaceRange(lower: Measurement(value: 3.0, unit: UnitSpeed.metersPerSecond),
                                      upper: Measurement(value: 5.0, unit: UnitSpeed.metersPerSecond), labelUnit: UnitPace.minutesPerMarathon)
            XCTAssertEqual(range!.start, Measurement(value: 42195 / (4 * 3600.0), unit: UnitSpeed.metersPerSecond).value)
            XCTAssertEqual(range!.end, Measurement(value: 42195 / (2 * 3600.0), unit: UnitSpeed.metersPerSecond).value)
            XCTAssertEqual(range!.labels, ["04:00", "03:30", "03:00", "02:30"])

            // 1609.344 m / 0.0 m/s / 60 s/min = Infinity
            // 1609.344 m / 5.0 m/s / 60 s/min = 5.364 == 5:22 per mile
            range = ReadablePaceRange(lower: Measurement(value: 0.0, unit: UnitSpeed.metersPerSecond),
                                      upper: Measurement(value: 5.0, unit: UnitSpeed.metersPerSecond), labelUnit: UnitPace.minutesPerMile)
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
    }
