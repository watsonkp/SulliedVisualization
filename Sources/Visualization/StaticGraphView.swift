import SwiftUI
import Accelerate

struct StaticGraphView: View {
    let dataPoints: [DataPoint]
    let xRange: (CGFloat, CGFloat)
    let yRange: (CGFloat, CGFloat)
    @State var xLabels: [String]
    @State var yLabels: [String]
    let showZones: Bool
    let zoneMaximum: Double?

    var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(yLabels, id: \.self) { label in
                            YAxisLabelView(label: label)
                        }
                    }
                    DataViewV2(data: dataPoints, xRange: xRange, yRange: yRange, showZones: showZones, zoneMaximum: zoneMaximum)
                }
                HStack(spacing: 0) {
                    AxisOrigin()
                    HStack(spacing: 0) {
                        ForEach(xLabels, id: \.self) { label in
                            XAxisLabelView(label: label)
                        }
                    }.frame(maxWidth: .infinity)
                }
            }
    }

    init(data: [DataPoint], xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), showZones: Bool = false, zoneMaximum: Double? = nil) {
        self.dataPoints = data
        self.xRange = xRange
        self.yRange = yRange
        self.xLabels = stride(from: self.xRange.0,
                              to: self.xRange.1,
                              by: (self.xRange.1 - self.xRange.0) / 4.0)
        .map({ String(format: "%.1f", $0) })
        self.yLabels = stride(from: self.yRange.0,
                              to: self.yRange.1,
                              by: (self.yRange.1 - self.yRange.0) / 5.0)
        .map({ String(format: "%.1f", $0) })
        .reversed()
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
    }
}
