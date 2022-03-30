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
            // Y-axis ticks
            context.stroke(Path {
                $0.move(to: CGPoint(x: 0, y: Int(size.height * 0.2)))
                $0.addLine(to: CGPoint(x: 10, y: Int(size.height * 0.2)))
                $0.move(to: CGPoint(x: 0, y: Int(size.height * 0.4)))
                $0.addLine(to: CGPoint(x: 10, y: Int(size.height * 0.4)))
                $0.move(to: CGPoint(x: 0, y: Int(size.height * 0.6)))
                $0.addLine(to: CGPoint(x: 10, y: Int(size.height * 0.6)))
                $0.move(to: CGPoint(x: 0, y: Int(size.height * 0.8)))
                $0.addLine(to: CGPoint(x: 10, y: Int(size.height * 0.8)))
            }, with: .color(Color.primary),
                           lineWidth: 2)
            // Axes
            context.stroke(Path {
                // y-axis
                $0.move(to: CGPoint(x: 1, y: 0))
                $0.addLine(to: CGPoint(x: 1, y: Int(size.height)))
                // x-axis
                $0.move(to: CGPoint(x: 0, y: Int(size.height)))
                $0.addLine(to: CGPoint(x: Int(size.width), y: Int(size.height)))
            }, with: .color(Color.primary),
                           lineWidth: 2)
            // X-Axis ticks
            context.stroke(Path {
                $0.move(to: CGPoint(x: Int(0.25 * size.width), y: Int(size.height) - 10))
                $0.addLine(to: CGPoint(x: Int(0.25 * size.width), y: Int(size.height)))
                $0.move(to: CGPoint(x: Int(0.5 * size.width), y: Int(size.height) - 10))
                $0.addLine(to: CGPoint(x: Int(0.5 * size.width), y: Int(size.height)))
                $0.move(to: CGPoint(x: Int(0.75 * size.width), y: Int(size.height) - 10))
                $0.addLine(to: CGPoint(x: Int(0.75 * size.width), y: Int(size.height)))
            }, with: .color(Color.primary),
                           lineWidth: 2)
            // Plot data points that are within the current magnification range
            for point in dataPoints {
                let origin = CGPoint(x: Int((point.x - xRange.0) / (xRange.1 - xRange.0) * size.width),
                                     y: Int(size.height - (point.y - yRange.0) / (yRange.1 - yRange.0) * size.height))
                context.fill(Path(ellipseIn: CGRect(origin: origin,
                                                      size: CGSize(width: 3, height: 3))),
                             with: .color(point.color))
            }
        }
    }

    init(data: ArraySlice<DataPoint>, xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), showZones: Bool = false, zoneMaximum: Double? = nil) {
        self.dataPoints = data
        self.xRange = xRange
        self.yRange = yRange
        if showZones {
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
    }
}
