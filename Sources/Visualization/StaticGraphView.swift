import SwiftUI
import Accelerate

struct StaticGraphView: View {
    let dataPoints: [DataPoint]
    let readableXRange: ReadableRange
    let readableYRange: ReadableRange
    let showZones: Bool
    let zoneMaximum: Double?

    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        YAxis(labels: readableYRange.labels.reversed())
                    }
                    ZStack {
                        DataViewV2(data: dataPoints,
                                   xRange: (Double(truncating: readableXRange.start as NSNumber),
                                            Double(truncating: readableXRange.end as NSNumber)),
                                   yRange: (Double(truncating: readableYRange.start as NSNumber),
                                            Double(truncating: readableYRange.end as NSNumber)),
                                   showZones: showZones,
                                   zoneMaximum: zoneMaximum)
                        GridLineOverlayView(xTicks: readableXRange.count, yTicks: readableYRange.count)
                    }
                }
                HStack(spacing: 0) {
                    AxisOrigin(positivePositions: readableYRange.integerDigits,
                               negativePositions: readableYRange.fractionDigits,
                               negative: readableYRange.end < 0)
                    HStack(spacing: 0) {
                        ForEach(readableXRange.labels, id: \.self) { label in
                            XAxisLabelView(label: label)
                        }
                    }.frame(maxWidth: .infinity)
                }
                if readableXRange.labelFactor != 1 || readableYRange.labelFactor != 1{
                    Text("Dimensions: \(readableYRange.labelFactorLabel) by \(readableXRange.labelFactorLabel)")
                }
            }
    }

    init(data: [DataPoint], xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), showZones: Bool = false, zoneMaximum: Double? = nil, xLabelCount: [Int] = [3, 4], yLabelCount: [Int] = [4, 5, 6]) {
        self.dataPoints = data
        self.readableXRange = ReadableRange(lower: xRange.0, upper: xRange.1, count: xLabelCount)
        self.readableYRange = ReadableRange(lower: yRange.0, upper: yRange.1, count: yLabelCount)
        self.showZones = showZones
        self.zoneMaximum = zoneMaximum
    }
}

struct StaticGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let x = vDSP.ramp(withInitialValue: 0.0, increment: Double.pi / 45.0, count: 180)
        let xRange: (CGFloat, CGFloat) = (min(0.0, x.min() ?? 0.0), x.max() ?? 1.0)
        let y = x.map({3 + sin($0)})
        let yRange: (CGFloat, CGFloat) = (min(0.0, y.min() ?? 0.0), y.max() ?? 1.0)
        let dataPoints = zip(x, y).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) })
        StaticGraphView(data: dataPoints, xRange: xRange, yRange: yRange, showZones: true)

        let x2 = Array(stride(from: 0.0, to: 7000, by: 10.0))
        let y2 = x2.map({3000 + 25000 * sin($0 / 10 * Double.pi / 180)})
        StaticGraphView(data: zip(x2, y2).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) }),
                        xRange: (x2.min() ?? 0.0, x2.max() ?? 1.0),
                        yRange: (y2.min() ?? 0.0, y2.max() ?? 1.0))
    }
}
