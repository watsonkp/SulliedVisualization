import Foundation

public final class UnitPace: Dimension {
    static let minutesPer200 = UnitPace(symbol: "200m", converter: UnitConverterLinear(coefficient: 1 / 0.2))
    static let minutesPer400 = UnitPace(symbol: "400m", converter: UnitConverterLinear(coefficient: 1 / 0.4))
    static let minutesPerKilometer = UnitPace(symbol: "km", converter: UnitConverterLinear(coefficient: 1))
    static let minutesPerMile = UnitPace(symbol: "mile", converter: UnitConverterLinear(coefficient: 1 / 1.609344))
    static let minutesPerFiveKilometer = UnitPace(symbol: "5 km", converter: UnitConverterLinear(coefficient: 1 / 5.0))
    static let minutesPerTenKilometer = UnitPace(symbol: "10 km", converter: UnitConverterLinear(coefficient: 1 / 10.0))
    static let minutesPerHalfMarathon = UnitPace(symbol: "half marathon", converter: UnitConverterLinear(coefficient: 1 / 21.0975))
    static let minutesPerMarathon = UnitPace(symbol: "marathon", converter: UnitConverterLinear(coefficient: 1 / 42.195))

    public static override func baseUnit() -> UnitPace {
        return self.minutesPerKilometer
    }

    static func fromSpeed(_ speed: Measurement<UnitSpeed>) -> Measurement<UnitPace> {
        // WARNING: When speed is 0. Pace is infinite.
        let metersPerSecond = speed.converted(to: UnitSpeed.metersPerSecond).value
        let value = 1000 / metersPerSecond / 60
        return Measurement(value: value, unit: minutesPerKilometer)
    }

    static func toSpeed(_ pace: Measurement<UnitPace>) -> Measurement<UnitSpeed> {
        let value = 1000 / pace.converted(to: minutesPerKilometer).value / 60
        return Measurement(value: value, unit: UnitSpeed.metersPerSecond)
    }
}
