import Foundation

// A range of numbers that include given lower and upper limits using one of a given number of increments. The increments will be a human reading friendly factor.
struct ReadableRange {
    let start: Decimal
    let end: Decimal
    let increment: Decimal
    let count: Int
    let labels: [String]
    let integerDigits: Int
    let fractionDigits: Int

    init(lower: Double, upper: Double, count: [Int] = [4, 5, 6]) {
        let magnitude = Decimal(upper - lower)
        var increments = [(Int, Decimal)]()
        let humanIncrements: [Decimal] = [1.0, 2.0, 5.0, 10.0]
        for nIncrements in count {
            let roughIncrement = magnitude / Decimal(nIncrements)
            let order = ReadableRange.order(roughIncrement)
            let scale = order > 0 ? pow(Decimal(10), order) : 1 / pow(Decimal(10), -1 * order)
            let newIncrement = humanIncrements.map({ $0 * scale }).first(where: { roughIncrement < $0 })
            if let newIncrement = newIncrement {
                increments.append((nIncrements, newIncrement))
            }
        }
        let finalIncrement = increments.min(by: { (Decimal($0.0) * $0.1 - magnitude) < (Decimal($1.0) * $1.1 - magnitude)}) ?? (5, Decimal(upper - lower) / Decimal(5))
        self.count = finalIncrement.0
        self.increment = finalIncrement.1

        var roughStart = Decimal(lower) / self.increment
        var roundStart = Decimal(signOf: roughStart, magnitudeOf: roughStart)
        NSDecimalRound(&roundStart, &roughStart, self.increment.exponent >= 0 ? 0 : -1 * self.increment.exponent, .down)
        roundStart *= self.increment
        self.start = roundStart
        self.end = self.start + Decimal(self.count) * self.increment

        self.fractionDigits = self.increment.exponent >= 0 ? 0 : -1 * self.increment.exponent
        let incrementOrder = ReadableRange.order(self.increment)
        self.integerDigits = incrementOrder >= 0 ? incrementOrder + 1 : 1
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = self.fractionDigits
        self.labels = stride(from: self.start,
                             to: self.end,
                             by: self.increment)
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
