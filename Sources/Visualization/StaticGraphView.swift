import SwiftUI
import Accelerate

struct StaticGraphView: View {
    let dataPoints: [DataPoint]
    let readableXRange: ReadableRangeProtocol
    let readableYRange: ReadableRangeProtocol
    let showZones: Bool
    let zoneMaximum: Double?
    let yVisibleDataRange: (CGFloat, CGFloat)

    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        YAxis(labels: readableYRange.labels.reversed())
                    }
                    ZStack {
                        DataViewV2(data: dataPoints,
                                   xRange: (readableXRange.start,
                                            readableXRange.end),
                                   yRange: yVisibleDataRange,
                                   showZones: showZones,
                                   zoneMaximum: zoneMaximum)
                        GridLineOverlayView(xTicks: readableXRange.count, yTicks: readableYRange.count)
                    }
                }
                HStack(spacing: 0) {
                    AxisOrigin(positivePositions: readableYRange.integerDigits,
                               negativePositions: readableYRange.fractionalDigits,
                               negative: readableYRange.end < 0)
                    HStack(spacing: 0) {
                        ForEach(readableXRange.labels, id: \.self) { label in
                            XAxisLabelView(label: label)
                        }
                    }.frame(maxWidth: .infinity)
                }
                Text("Dimensions: \(readableYRange.labelFactorLabel) by \(readableXRange.labelFactorLabel)")
            }
    }

    init(data: [DataPoint], showZones: Bool = false, zoneMaximum: Double? = nil, xLabelCount: [Int] = [3, 4], yLabelCount: [Int] = [4, 5, 6], xDimension: Dimension? = nil, yDimension: Dimension? = nil, xDataUnit: Unit? = nil, yDataUnit: Unit? = nil) {
        self.dataPoints = data
        // Include x=0 and use a range of [0.0, 1.0] when min and max fail due to missing data
        let xRange = (CGFloat(data.min(by: { $0.x < $1.x })?.x ?? 0.0), CGFloat(data.max(by: { $0.x < $1.x })?.x ?? 1.0))
        let yRange = (CGFloat(data.min(by: { $0.y < $1.y })?.y ?? 0.0), CGFloat(data.max(by: { $0.y < $1.y })?.y ?? 1.0))

        self.showZones = showZones
        self.zoneMaximum = zoneMaximum

        switch xDimension {
        case let duration as UnitDuration:
            self.readableXRange = ReadableDurationRange(lower: Measurement(value: xRange.0, unit: duration), upper: Measurement(value: xRange.1, unit: duration))
        default:
            self.readableXRange = ReadableRange(lower: xRange.0, upper: xRange.1, count: xLabelCount)
        }

        switch yDimension {
        case let duration as UnitDuration:
            self.readableYRange = ReadableDurationRange(lower: Measurement(value: yRange.0, unit: duration), upper: Measurement(value: yRange.1, unit: duration))
        case let pace as UnitPace:
            if let dataUnit = yDataUnit as? UnitPace {
                let mean = self.dataPoints.reduce(into: 0.0, { $0 = $0 + $1.y }) / CGFloat(self.dataPoints.count)
                let σ = sqrt(self.dataPoints.reduce(into: 0.0, { $0 = $0 + pow($1.y - mean, 2.0) }) / CGFloat(self.dataPoints.count))
                let lower = Measurement(value: mean, unit: dataUnit)
                let upper = Measurement(value: max(yRange.0, mean - σ), unit: dataUnit)
                self.readableYRange = ReadablePaceRange(lower: lower,
                                                        upper: upper,
                                                        labelUnit: pace) ?? ReadableRange(lower: yRange.1, upper: yRange.0, count: yLabelCount)
            } else {
                self.readableYRange = ReadableRange(lower: yRange.1, upper: yRange.0, count: yLabelCount)
            }
        default:
            self.readableYRange = ReadableRange(lower: yRange.0, upper: yRange.1, count: yLabelCount)
        }

        // Scale readable y range start and end when the label unit differs from the data unit
        if let labelUnit = yDimension, let dataUnit = yDataUnit as? Dimension {
            self.yVisibleDataRange = (CGFloat(Measurement(value: readableYRange.start, unit: labelUnit).converted(to: dataUnit).value),
                                      CGFloat(Measurement(value: readableYRange.end, unit: labelUnit).converted(to: dataUnit).value))
        } else {
            self.yVisibleDataRange = (readableYRange.start, readableYRange.end)
        }
    }

    public init(x: [Double], y: [Double],
                color: Color = Color.accentColor,
                showZones: Bool = false,
                zoneMaximum: Double? = nil,
                xLabelCount: [Int] = [3, 4], yLabelCount: [Int] = [4, 5, 6],
                xDimension: Dimension? = nil, yDimension: Dimension? = nil,
                xDataUnit: Unit? = nil, yDataUnit: Unit? = nil) {
        self.init(data: zip(x, y).filter({ $0.0.isFinite && $0.1.isFinite }).map({ DataPoint(x: $0.0, y: $0.1, color: color) }),
                  showZones: showZones, zoneMaximum: zoneMaximum,
                  xLabelCount: xLabelCount, yLabelCount: yLabelCount,
                  xDimension: xDimension, yDimension: yDimension,
                  xDataUnit: xDataUnit, yDataUnit: yDataUnit)
    }
}

struct StaticGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let x = vDSP.ramp(withInitialValue: 0.0, increment: Double.pi / 45.0, count: 180)
        let y = x.map({3 + sin($0)})
        let dataPoints = zip(x, y).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) })
        StaticGraphView(data: dataPoints, showZones: true)

        let x2 = Array(stride(from: 0.0, to: 7000, by: 10.0))
        let y2 = x2.map({3000 + 25000 * sin($0 / 10 * Double.pi / 180)})
        StaticGraphView(data: zip(x2, y2).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) }))

        StaticGraphView(data: zip(x2, y2).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) }),
                        xDimension: UnitDuration.seconds)

        let y3 = x2.map({317.0 / 60 + 32 / 60.0 * sin($0 / 10 * Double.pi / 180)})
        StaticGraphView(data: zip(x2, y3).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) }),
                        xDimension: UnitDuration.seconds,
                        yDimension: UnitPace.minutesPerKilometer,
                        yDataUnit: UnitPace.minutesPerKilometer)

        StaticGraphView(data: zip(x2, y3).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) }),
                        xDimension: UnitDuration.seconds,
                        yDimension: UnitPace.minutesPerMile,
                        yDataUnit: UnitPace.minutesPerKilometer)
    }
}
