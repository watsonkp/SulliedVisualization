import Foundation

// A range of numbers that include given lower and upper limits using one of a given number of increments. The increments will be a human reading friendly factor.
struct ReadableRange {
    let start: Decimal
    let end: Decimal
    let increment: Decimal
    let count: Int
    let labels: [String]
    let labelFactor: Decimal
    var labelFactorLabel: String {
        get {
            formatter.string(from: labelFactor as NSNumber) ?? "??"
        }
    }
    let integerDigits: Int
    let fractionDigits: Int
    let formatter = NumberFormatter()

    init(lower: Double, upper: Double, count: [Int] = [4, 5, 6]) {
        let magnitude = Decimal(upper - lower)
        var increments = [(Int, Decimal)]()
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
                    increments.append((nIncrements, increment))
                }
            }
        }
        let finalIncrement = increments.min(by: { (Decimal($0.0) * $0.1 - magnitude) < (Decimal($1.0) * $1.1 - magnitude)}) ?? (5, Decimal(upper - lower) / Decimal(5))
        self.count = finalIncrement.0
        self.increment = finalIncrement.1

        var roughStart = Decimal(lower) / self.increment
        var roundStart = Decimal(signOf: roughStart, magnitudeOf: roughStart)
        NSDecimalRound(&roundStart, &roughStart, 0, .down)
        roundStart *= self.increment
        self.start = roundStart
        self.end = self.start + Decimal(self.count) * self.increment

        // Limit labels to 3 or 4 digits by factoring out 10E(3 * n)
        let rangeOrder = ReadableRange.order(self.end - self.start) / 3 * 3
        self.labelFactor = rangeOrder >= 0 ? pow(10, rangeOrder) : 1 / pow(10, -1 * rangeOrder + 3)
        let endOrder = ReadableRange.order(self.end / self.labelFactor)
        self.integerDigits = endOrder >= 0 ? endOrder + 1 : 1
        let incrementOrder = ReadableRange.order(increment / self.labelFactor)
        self.fractionDigits = incrementOrder >= 0 ? 0 : -1 * incrementOrder

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = self.fractionDigits
        formatter.maximumFractionDigits = self.fractionDigits
        self.labels = stride(from: self.start / self.labelFactor,
                             to: self.end / self.labelFactor,
                             by: self.increment / self.labelFactor)
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
