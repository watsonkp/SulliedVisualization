import SwiftUI
import Accelerate

struct DataViewV2: View {
    let dataPoints: ArraySlice<DataPoint>
    let xRange: (CGFloat, CGFloat)
    let yRange: (CGFloat, CGFloat)
    let zones: [Zone]?
    var body: some View {
        Canvas { context, size in
            // Mark zones on data area if they exist
            if let zones = zones {
                context.opacity = 0.5
                for zone in zones {
                    // Draw zones that fit in the current visible range
                    if zone.maximum <= yRange.1 && zone.minimum >= yRange.0 {
                        context.fill(Path(CGRect(origin: CGPoint(x: 0.0, y: size.height - (zone.maximum - yRange.0) / (yRange.1 - yRange.0) * size.height),
                                                 size: CGSize(width: size.width, height: (zone.maximum - zone.minimum) / (yRange.1 - yRange.0) * size.height))),
                                     with: .color(zone.color))
                    } else if zone.maximum > yRange.1 && zone.minimum >= yRange.0 {
                        // Draw zone with a maximum greater than the current visible range
                        context.fill(Path(CGRect(origin: CGPoint(x: 0.0, y: 0.0),
                                                 size: CGSize(width: size.width, height: (yRange.1 - zone.minimum) / (yRange.1 - yRange.0) * size.height))),
                                     with: .color(zone.color))
                    } else if zone.maximum <= yRange.1 && zone.minimum < yRange.0 {
                        // Draw zone with a minimum less than the current visible range
                        context.fill(Path(CGRect(origin: CGPoint(x: 0.0, y: size.height - (zone.maximum - yRange.0) / (yRange.1 - yRange.0) * size.height),
                                                 size: CGSize(width: size.width, height: (zone.maximum - yRange.0) / (yRange.1 - yRange.0) * size.height))),
                                     with: .color(zone.color))
                    } else if zone.maximum > yRange.1 && zone.minimum < yRange.0 {
                        // Draw zone that covers the entire visible range
                        context.fill(Path(CGRect(origin: CGPoint(x: 0.0, y: 0.0),
                                                 size: CGSize(width: size.width, height: size.height))),
                                     with: .color(zone.color))
                    }
                }
                context.opacity = 1.0
            }
            // Plot data points that are within the current magnification range
            for point in dataPoints {
                var origin = CGPoint(x: Int((point.x - xRange.0) / (xRange.1 - xRange.0) * size.width),
                                     y: Int(size.height - (point.y - yRange.0) / (yRange.1 - yRange.0) * size.height))
                if origin.y < 0.0 {
                    origin.y = 0.0
                    context.stroke(Path(ellipseIn: CGRect(origin: origin,
                                                        size: CGSize(width: 3, height: 3))),
                                   with: .color(.gray))
                } else if origin.y > size.height {
                    origin.y = size.height
                    context.stroke(Path(ellipseIn: CGRect(origin: origin,
                                                        size: CGSize(width: 3, height: 3))),
                                   with: .color(.gray))
                } else {
                    context.fill(Path(ellipseIn: CGRect(origin: origin,
                                                        size: CGSize(width: 3, height: 3))),
                                 with: .color(point.color))
                }
            }
        }
    }

    init(data: ArraySlice<DataPoint>, xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), showZones: Bool = false, zoneMaximum: Double? = nil) {
        self.dataPoints = data
        self.xRange = xRange
        self.yRange = yRange
        if showZones {
            // TODO: Zones do not account for negative data values.
            let yRangeMax = zoneMaximum ?? CGFloat(yRange.1)
            self.zones = zip(stride(from: 100.0, to: 50.0, by: -10.0).map({ yRangeMax * $0 / 100.0}),
                             [Color.red, Color.yellow, Color.green, Color.blue, Color.gray])
            .map({ Zone(minimum: $0.0 - yRangeMax / 10.0, maximum: $0.0, color: $0.1) })
        } else {
            self.zones = nil
        }
    }

    init(data: [DataPoint], xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), showZones: Bool = false, zoneMaximum: Double? = nil) {
        self.init(data: ArraySlice(data), xRange: xRange, yRange: yRange, showZones: showZones, zoneMaximum: zoneMaximum)
    }
}

struct DataViewV2_Previews: PreviewProvider {
    static var previews: some View {
        let x = vDSP.ramp(withInitialValue: 0.0, increment: Double.pi / 45.0, count: 180)
        let xRange: (CGFloat, CGFloat) = (min(0.0, x.min() ?? 0.0), x.max() ?? 1.0)
        let y = x.map({3 + sin($0)})
        let yRange: (CGFloat, CGFloat) = (min(0.0, y.min() ?? 0.0), y.max() ?? 1.0)
        let dataPoints = zip(x, y).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) })
        DataViewV2(data: dataPoints, xRange: xRange, yRange: yRange, showZones: true)
            .padding()

        let x2 = Array(stride(from: 0.0, to: 7000, by: 10.0))
        let xRange2: (CGFloat, CGFloat) = (x2.min() ?? 0.0, x2.max() ?? 1.0)
        let y2 = x2.map({ 90 + 100 * sin($0 / 10 * Double.pi / 180) })
        let yRange2: (CGFloat, CGFloat) = (y2.min() ?? 0.0, y2.max() ?? 1.0)
        let dataPoints2 = zip(x2, y2).map({ DataPoint(x: $0.0, y: $0.1, color: Color.purple) })
        DataViewV2(data: dataPoints2, xRange: xRange2, yRange: (yRange2.0 + 0.1 * yRange2.1, 0.9 * yRange2.1), showZones: true)
            .padding()
    }
}
