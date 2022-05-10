import Foundation
import SwiftUI

// TODO: Add a separator property for : or . symbols in labels.
protocol ReadableRangeProtocol {
    var count: Int { get }
    var labels: [String] { get }
    var start: CGFloat { get }
    var end: CGFloat { get }
    var integerDigits: Int { get }
    var fractionalDigits: Int { get }
    var labelFactor: Decimal { get }
    var labelFactorLabel: String { get }
}

struct ReadablePaceRange: ReadableRangeProtocol {
    let count: Int
    let labels: [String]
    let start: CGFloat
    let end: CGFloat
    let integerDigits: Int
    let fractionalDigits: Int = 0
    let separators: Int
    let labelFactor = Decimal(1)
    let labelFactorLabel: String

    // Lesser pace values are greater speeds, so some calculations are negative instead of positive.
    init?(lower: Measurement<UnitPace>, upper: Measurement<UnitPace>, labelUnit: UnitPace = UnitPace.minutesPerKilometer) {
        // Find a human readable increment that covers the upper and lower values while starting at an integer multiple of the increment and using no more than the specified count of occurences.
        // Ascending order to prefer smallest and most frequent increment.
        let humanReadable = [1.0, 2.0, 5.0, 10.0, 15.0, 30.0,
                             60.0, 2 * 60.0, 5 * 60.0, 10 * 60.0, 15 * 60.0, 30 * 60.0,
                             3600.0, 2 * 3600.0, 6 * 3600.0, 12 * 3600.0, 24 * 3600.0]
        // Maximum factor of seconds and minutes combined with maximum count of 5 results in switching units after a magnitude of 2.5.
        let maximumCount = 5
        let lowerPace = lower.converted(to: labelUnit)
        let upperPace = upper.converted(to: labelUnit)
        // WARNING: A speed of zero results in a pace of infinity.
        // It's unclear how infinity should be handled to prevent runtime crashes.
        guard lowerPace.value.isFinite && upperPace.value.isFinite else {
            return nil
        }
        var options = [(Measurement<UnitPace>, Int, Measurement<UnitPace>)]()
        for factor in humanReadable {
            let increment = Measurement(value: factor / 60.0, unit: labelUnit)
            // Lower pace is greater in magnitude than upper pace. Starting pace value must be greater than or equal to lower pace. Round up.
            let start = Measurement(value: (lowerPace.value / increment.value).rounded(.up) * increment.value, unit: labelUnit)
            if start >= lowerPace && (start - Double(maximumCount) * increment) <= upperPace {
                let n = Int(((start - upperPace).value / increment.value).rounded(.up))
                options.append((start, n, increment))
                // Search stops after finding the first human readable factor that satisfies the conditions.
                break
            }
        }
        let (paceStart, count, paceIncrement) = options.first ?? (lowerPace, 4, (lowerPace - upperPace) / 4.0)
        self.count = count
        self.start = paceStart.value
        self.end = (paceStart - Double(count) * paceIncrement).value

        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .long
        let labelFormatter = DateComponentsFormatter()
        labelFormatter.zeroFormattingBehavior = .pad
        if paceStart <= Measurement(value: 90.0 / 60, unit: labelUnit) {
            labelFormatter.allowedUnits = [.second]
            self.labelFactorLabel = "seconds / " + measurementFormatter.string(from: labelUnit)
        } else if paceStart <= Measurement(value: 60, unit: labelUnit) {
            labelFormatter.allowedUnits = [.minute, .second]
            self.labelFactorLabel = "minutes / " + measurementFormatter.string(from: labelUnit)
        } else {
            labelFormatter.allowedUnits = [.hour, .minute]
            self.labelFactorLabel = "hours / " + measurementFormatter.string(from: labelUnit)
        }
        let secondsStart = Int((paceStart.value * 60.0).rounded())
        let secondsIncrement = Int((paceIncrement.value * 60.0).rounded())
        self.labels = stride(from: secondsStart,
                             to: secondsStart - self.count * secondsIncrement,
                             by: -1 * secondsIncrement)
        .map({ labelFormatter.string(from: DateComponents(second: $0)) ?? "??:??" })
        self.separators = self.labels.last?.reduce(into: 0, { $0 += $1 == ":" ? 1 : 0 }) ?? 0
        self.integerDigits = self.labels.last?.count ?? 0 - self.separators
    }
}

struct ReadableDurationRange: ReadableRangeProtocol {
    let start: CGFloat
    let end: CGFloat
    let count: Int
    let labels: [String]
    let integerDigits: Int
    let fractionalDigits: Int = 0
    let labelFactor = Decimal(1)
    let labelFactorLabel: String

    init(lower: Measurement<UnitDuration>, upper: Measurement<UnitDuration>) {
        let countOptions: [Int] = [3, 4, 5]
        // Keying the dictionary using a UnitDuration class var (UnitDuration.seconds) leads to unpredictable results.
        // Sometimes a key is found, sometimes it isn't. UnitDuration.milliseconds produced this behaviour during testing.
        let humanReadable: [String : [Double]] = ["ps" : [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0],
                                                  "ns" : [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0],
                                                  "µs" : [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0],
                                                  "ms" : [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0],
                                                  "s" : [1.0, 2.0, 5.0, 10.0, 15.0, 30.0],
                                                  "min" : [1.0, 2.0, 5.0, 10.0, 15.0, 30.0],
                                                  "hr" : [1.0, 2.0, 5.0, 10.0, 12.0, 24.0]]
        let magnitude = upper - lower
        var increments = [(Measurement<UnitDuration>, Int, Measurement<UnitDuration>)]()
        let incrementUnit = ReadableDurationRange.readableUnit(magnitude)
        for n in countOptions {
            for factor in humanReadable[incrementUnit.symbol] ?? [1.0, 2.0, 5.0, 10.0] {
                let increment = Measurement(value: factor, unit: incrementUnit)
                // Can not divide a Measurement by another Measurement
                var roughStartN = Decimal(lower.converted(to: UnitDuration.seconds).value / increment.converted(to: UnitDuration.seconds).value)
                var roundStartN = Decimal(signOf: roughStartN, magnitudeOf: roughStartN)
                NSDecimalRound(&roundStartN, &roughStartN, 0, .down)
                let start = Double(truncating: roundStartN as NSNumber) * increment
                let end = start + Double(n) * increment
                if start <= lower && end >= upper {
                    increments.append((start, n, increment))
                }
            }
        }
        let (start, count, increment) = increments.min(by: { Double($0.1) * $0.2 < Double($1.1) * $1.2 }) ?? (lower, 5, magnitude / 5.0)
        self.start = CGFloat(start.converted(to: lower.unit).value)
        self.count = count
        self.end = self.start + CGFloat(self.count) * increment.converted(to: lower.unit).value

        // Use Decimals for labels to avoid inexact floating point representations of human readable decimal numbers.
        let formatter = NumberFormatter()
        // The human readable factors never result in fractional increments.
        formatter.maximumFractionDigits = self.fractionalDigits
        var decimalStart = Decimal(start.value)
        var rough = Decimal(signOf: decimalStart, magnitudeOf: decimalStart)
        NSDecimalRound(&decimalStart, &rough, 0, .plain)
        var decimalIncrement = Decimal(increment.value)
        rough = Decimal(signOf: decimalIncrement, magnitudeOf: decimalIncrement)
        NSDecimalRound(&decimalIncrement, &rough, 0, .plain)
        self.labels = stride(from: decimalStart,
                             to: decimalStart + Decimal(self.count) * decimalIncrement,
                             by: decimalIncrement)
        .map({ formatter.string(from: $0 as NSNumber) ?? "??" })
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .long
        self.labelFactorLabel = measurementFormatter.string(from: increment.unit)
        self.integerDigits = self.labels.last?.count ?? 1
    }

    private static func readableUnit(_ x: Measurement<UnitDuration>) -> UnitDuration {
        if x <= Measurement(value: 5 * 0.5, unit: UnitDuration.nanoseconds) {
            return UnitDuration.picoseconds
        } else if x <= Measurement(value: 5 * 0.5, unit: UnitDuration.microseconds) {
            return UnitDuration.nanoseconds
        } else if x <= Measurement(value: 5 * 0.5, unit: UnitDuration.milliseconds) {
            return UnitDuration.microseconds
        } else if x <= Measurement(value: 5 * 0.5, unit: UnitDuration.seconds) {
            return UnitDuration.milliseconds
        } else if x <= Measurement(value: 5 * 0.5, unit: UnitDuration.minutes) {
            return UnitDuration.seconds
        } else if x <= Measurement(value: 5 * 0.5, unit: UnitDuration.hours) {
            return UnitDuration.minutes
        } else {
            return UnitDuration.hours
        }
    }
}

// A range of numbers that include given lower and upper limits using one of a given number of increments. The increments will be a human reading friendly factor.
struct ReadableRange: ReadableRangeProtocol {
    let start: CGFloat
    let end: CGFloat
    let count: Int
    let labels: [String]
    let labelFactor: Decimal
    var labelFactorLabel: String {
        get {
            formatter.string(from: labelFactor as NSNumber) ?? "??"
        }
    }
    let integerDigits: Int
    let fractionalDigits: Int
    let formatter = NumberFormatter()

    init(lower: Double, upper: Double, count: [Int] = [4, 5, 6]) {
        let magnitude = Decimal(upper - lower)
        var increments = [(Decimal, Int, Decimal)]()
        let humanIncrements: [Decimal] = [1.0, 2.0, 5.0, 10.0]
        for nIncrements in count {
            for humanFactor in humanIncrements {
                let roughIncrement = magnitude / Decimal(nIncrements)
                let order = ReadableRange.order(roughIncrement)
                let scale = order > 0 ? pow(Decimal(10), order) : 1 / pow(Decimal(10), -1 * order)
                let increment = humanFactor * scale
                var roughStart = Decimal(lower) / increment
                var roundStart = Decimal(signOf: roughStart, magnitudeOf: roughStart)
                NSDecimalRound(&roundStart, &roughStart, 0, .down)
                roundStart *= increment
                let end = roundStart + Decimal(nIncrements) * increment
                if roundStart <= Decimal(lower) && end >= Decimal(upper) {
                    increments.append((roundStart, nIncrements, increment))
                }
            }
        }
        let (decimalStart, n, increment) = increments.min(by: { (Decimal($0.1) * $0.2) < (Decimal($1.1) * $1.2)}) ?? (Decimal(lower), 5, Decimal(upper - lower) / Decimal(5))
        self.count = n
        self.start = CGFloat(truncating: decimalStart as NSNumber)
        let decimalEnd = decimalStart + Decimal(self.count) * increment
        self.end = CGFloat(truncating: decimalEnd as NSNumber)

        // Limit labels to 3 or 4 digits by factoring out 10E(3 * n)
        let rangeOrder = ReadableRange.order(decimalEnd - decimalStart) / 3 * 3
        self.labelFactor = rangeOrder >= 0 ? pow(10, rangeOrder) : 1 / pow(10, -1 * rangeOrder + 3)
        let endOrder = ReadableRange.order(decimalEnd / self.labelFactor)
        self.integerDigits = endOrder >= 0 ? endOrder + 1 : 1
        let incrementOrder = ReadableRange.order(increment / self.labelFactor)
        self.fractionalDigits = incrementOrder >= 0 ? 0 : -1 * incrementOrder

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = self.fractionalDigits
        formatter.maximumFractionDigits = self.fractionalDigits
        self.labels = stride(from: decimalStart / self.labelFactor,
                             to: decimalEnd / self.labelFactor,
                             by: increment / self.labelFactor)
        .map({ formatter.string(from: $0 as NSNumber) ?? "??" })
    }

    private static func order(_ x: Decimal) -> Int {
        var magnitude = x.magnitude
        var n = 0
        if magnitude > 10 {
            // [10, ∞)
            while magnitude > 10 {
                magnitude /= 10
                n += 1
            }
            return n
        } else if magnitude < 1  && magnitude > 0 {
            // (0, 1)
            while magnitude < 1 {
                magnitude *= 10
                n += 1
            }
            return -n
        } else {
            // 0, [1, 10)
            return n
        }
    }
}
