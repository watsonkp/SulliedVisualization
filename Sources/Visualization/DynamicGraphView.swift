import SwiftUI
import Accelerate

struct AxisOrigin: View {
    var body: some View {
        VStack {
            Text("0,0")
                .monospacedDigit()
                .padding()
                .foregroundColor(Color.secondary)
        }
    }
}

struct XAxisLabelView: View {
    let label: String
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text(label)
                    .monospacedDigit()
                    .padding([.top, .bottom, .trailing])
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }
}

struct YAxisLabelView: View {
    let label: String
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Text(label)
                    .monospacedDigit()
                    .padding([.leading, .trailing, .top])
            }
        }.frame(maxHeight: .infinity)
    }
}

struct DataPoint {
    let x: CGFloat
    let y: CGFloat
    let color: Color
}

struct Zone {
    let minimum: CGFloat
    let maximum: CGFloat
    let color: Color
}

public struct DynamicGraphView: View {
    let dataPoints: [DataPoint]
    let colors: [Color]
    let xRange: (CGFloat, CGFloat)
    let yRange: (CGFloat, CGFloat)
    @State var magnification: Double = 1.0
    @State var visibleStartIndex: Int
    @State var visibleEndIndex: Int
    @State var visibleXRange: (CGFloat, CGFloat)
    @State var visibleYRange: (CGFloat, CGFloat)
    @State var xLabels: [String]
    @State var yLabels: [String]
    let zones: [Zone]?
    @State var isInteracting = false

    public var body: some View {
        StaticGraphView(data: dataPoints, xRange: xRange, yRange: yRange, showZones: zones != nil)
        .border(Color.accentColor)
        .gesture(TapGesture().onEnded({ value in
            isInteracting = true
        }))
        .sheet(isPresented: $isInteracting, content: {
            VStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(yLabels, id: \.self) { label in
                                YAxisLabelView(label: label)
                            }
                        }
                        GeometryReader { proxy in
                            Canvas { context, size in
                                // Mark zones on data area if they exist
                                if let zones = zones {
                                    context.opacity = 0.5
                                    for zone in zones {
                                        // Draw zones that fit in the current visible range
                                        if zone.maximum <= self.visibleYRange.1 && zone.minimum >= self.visibleYRange.0 {
                                            context.fill(Path(CGRect(origin: CGPoint(x: 0.0, y: size.height - (zone.maximum - self.visibleYRange.0) / (self.visibleYRange.1 - self.visibleYRange.0) * size.height),
                                                                     size: CGSize(width: size.width, height: (zone.maximum - zone.minimum) / (self.visibleYRange.1 - self.visibleYRange.0) * size.height))),
                                                         with: .color(zone.color))
                                        } else if zone.maximum > self.visibleYRange.1 && zone.minimum >= self.visibleYRange.0 {
                                            // Draw zone with a maximum greater than the current visible range
                                            context.fill(Path(CGRect(origin: CGPoint(x: 0.0, y: 0.0),
                                                                     size: CGSize(width: size.width, height: (self.visibleYRange.1 - zone.minimum) / (self.visibleYRange.1 - self.visibleYRange.0) * size.height))),
                                                         with: .color(zone.color))
                                        } else if zone.maximum <= self.visibleYRange.1 && zone.minimum < self.visibleYRange.0 {
                                            // Draw zone with a minimum less than the current visible range
                                            context.fill(Path(CGRect(origin: CGPoint(x: 0.0, y: size.height - (zone.maximum - self.visibleYRange.0) / (self.visibleYRange.1 - self.visibleYRange.0) * size.height),
                                                                     size: CGSize(width: size.width, height: (zone.maximum - self.visibleYRange.0) / (self.visibleYRange.1 - self.visibleYRange.0) * size.height))),
                                                         with: .color(zone.color))
                                        } else if zone.maximum > self.visibleYRange.1 && zone.minimum < self.visibleYRange.0 {
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
                                for point in dataPoints[visibleStartIndex..<visibleEndIndex] {
                                    let origin = CGPoint(x: Int((point.x - visibleXRange.0) / (visibleXRange.1 - visibleXRange.0) * size.width),
                                                         y: Int(size.height - (point.y - visibleYRange.0) / (visibleYRange.1 - visibleYRange.0) * size.height))
                                    context.fill(Path(ellipseIn: CGRect(origin: origin,
                                                                          size: CGSize(width: 3, height: 3))),
                                                 with: .color(point.color))
                                }
                            }
                            .gesture(MagnificationGesture().onEnded { value in
                                // TODO: It seems like magnification can be infinity.
                                // TODO: Handle large magnifications with exponential decay and a hard limit? min(10.0, Double.infinity) works.
                                self.magnification = max(1.0, value * self.magnification)
                                updateMagnification()
                                updateXLabels()
                                updateYLabels()
                            })
                            .gesture(DragGesture().onEnded { value in
                                // Don't pan without zoom. Panning fits y data and doesn't force the inclusion of 0.
                                // Panning at 1.0 zoom only adjusts to fit the y values, which feels surprising and unintuitive.
                                if magnification == 1.0 {
                                    return
                                }
                                let maxLeft = self.visibleXRange.0 - self.xRange.0
                                let maxRight = self.xRange.1 - self.visibleXRange.1
                                var drag = (self.visibleXRange.1 - self.visibleXRange.0) * (value.location.x - value.startLocation.x) / proxy.size.width
                                // A pan > 0 is exposing more data from the left. maxLeft >= 0. A pan < 0 is unaffected by this statement.
                                drag = min(drag, maxLeft)
                                // A pan < 0 is exposing more data from the right. maxRight >= 0. A pan > 0 is unaffected by this statement.
                                drag = max(drag, -maxRight)
                                // Translate the data in the opposite direction of the drag aka "Natural scrolling".
                                applyPan(-drag)
                                updateXLabels()
                                // Y axis labels may change after panning if the visible minimum and or maximum change.
                                updateYLabels()
                            })
                        }
                    }
                    HStack(spacing: 0) {
                        AxisOrigin()
                        HStack(spacing: 0) {
                            ForEach(xLabels, id: \.self) { label in
                                XAxisLabelView(label: label)
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }.padding()
                Button(action: { isInteracting = false}) {
                    Text("Dismiss")
                }
        }
        })
    }

    // Plot floating point data
    public init(x: [Double], y: [Double], color: Color = Color.accentColor, showZones: Bool = false, zoneMaximum: Double? = nil) {
        self.dataPoints = zip(x, y).map({ DataPoint(x: $0.0, y: $0.1, color: color) })
        self.colors = [color]
        // Include x=0 and use a range of [0.0, 1.0] when min and max fail due to missing data
        self.xRange = (min(0.0, CGFloat(x.min() ?? 0.0)), CGFloat(x.max() ?? 1.0))
        // Include y=0 and use a range of [0.0, 1.0] when min and max fail due to missing data
        self.yRange = (min(0.0, CGFloat(y.min() ?? 0.0)), CGFloat(y.max() ?? 1.0))
        self.visibleStartIndex = 0
        self.visibleEndIndex = x.count
        self.visibleXRange = self.xRange
        self.visibleYRange = self.yRange
        self.xLabels = stride(from: self.xRange.0,
                              to: self.xRange.1,
                              by: (self.xRange.1 - self.xRange.0) / 4.0)
        .map({ String(format: "%.1f", $0) })
        self.yLabels = stride(from: self.yRange.0,
                              to: self.yRange.1,
                              by: (self.yRange.1 - self.yRange.0) / 5.0)
        .map({ String(format: "%.1f", $0) })
        .reversed()

        if showZones {
            self.zones = DynamicGraphView.createZones(zoneMax: zoneMaximum ?? CGFloat(y.max() ?? 1.0))
        } else {
            self.zones = nil
        }
    }

    // Plot multiple series of floating point data
    public init(data: [([Double], [Double])], colors: [Color] = [Color.red, Color.green, Color.blue], showZones: Bool = false, zoneMaximum: Double? = nil) {
        // Repeat the colors array if it is shorter than the data array.
        // Check for an empty colors array
        self.colors = Array(Array(repeating: colors.count > 0 ? colors : [Color.red, Color.green, Color.blue],
                                  count: 1 + data.count / colors.count)
            .reduce(into: [Color](), { $0.append(contentsOf: $1) })[0..<data.count])
        self.dataPoints = DynamicGraphView.createDataPoints(data: data, colors: self.colors)
        // Include x=0 and use a range of [0.0, 1.0] when min and max fail due to missing data
        self.xRange = (min(0.0, self.dataPoints.min(by: { $0.x < $1.x })?.x ?? 0.0),
                       self.dataPoints.max(by: { $0.x < $1.x })?.x ?? 1.0)
        // Include y=0 and use a range of [0.0, 1.0] when min and max fail due to missing data
        let yRangeMax = self.dataPoints.max(by: { $0.y < $1.y })?.y ?? 1.0
        self.yRange = (min(0.0, self.dataPoints.min(by: { $0.y < $1.y })?.y ?? 0.0),
                       yRangeMax)
        self.visibleStartIndex = 0
        self.visibleEndIndex = self.dataPoints.count
        self.visibleXRange = self.xRange
        self.visibleYRange = self.yRange
        self.xLabels = stride(from: self.xRange.0,
                              to: self.xRange.1,
                              by: (self.xRange.1 - self.xRange.0) / 4.0)
        .map({ String(format: "%.1f", $0) })
        self.yLabels = stride(from: self.yRange.0,
                              to: self.yRange.1,
                              by: (self.yRange.1 - self.yRange.0) / 5.0)
        .map({ String(format: "%.1f", $0) })
        .reversed()

        if showZones {
            self.zones = DynamicGraphView.createZones(zoneMax: zoneMaximum ?? yRangeMax)
        } else {
            self.zones = nil
        }
    }

    // Plot integer data
    public init(x: [Double], y: [Int], color: Color = Color.accentColor, showZones: Bool = false, zoneMaximum: Double? = nil) {
        self.init(x: x, y: y.map({ CGFloat($0) }), color: color, showZones: showZones, zoneMaximum: zoneMaximum)
    }

    // Plot multiple series of integer data
    public init(data: [([Double], [Int])], colors: [Color] = [Color.red, Color.green, Color.blue], showZones: Bool = false, zoneMaximum: Double? = nil) {
        self.init(data: data.map({ ($0.0, $0.1.map({ CGFloat($0) })) }), colors: colors, showZones: showZones, zoneMaximum: zoneMaximum)
    }

    private static func createDataPoints(data: [([Double], [Double])], colors: [Color]) -> [DataPoint] {
        var dataPoints = [DataPoint]()
        for ((x, y), color) in zip(data, colors) {
            dataPoints.append(contentsOf: zip(x, y).map({ DataPoint(x: $0.0, y: $0.1, color: color) }))
        }
        return dataPoints
    }

    private static func createZones(zoneMax: CGFloat) -> [Zone] {
        return zip(stride(from: 100.0, to: 50.0, by: -10.0).map({ zoneMax * $0 / 100.0}),
                         [Color.red, Color.yellow, Color.green, Color.blue, Color.gray])
        .map({ Zone(minimum: $0.0 - zoneMax / 10.0, maximum: $0.0, color: $0.1) })
    }

    func updateXLabels() {
        let xIncrement = (self.visibleXRange.1 - self.visibleXRange.0) / 4.0
        self.xLabels = stride(from: self.visibleXRange.0, to: self.visibleXRange.1, by: xIncrement)
            .map({ String(format: "%.1f", $0) })
    }

    func updateYLabels() {
        let yIncrement = (self.visibleYRange.1 - self.visibleYRange.0) / 5.0
        self.yLabels = stride(from: self.visibleYRange.0, to: self.visibleYRange.1, by: yIncrement)
            .map({ String(format: "%.1f", $0) }).reversed()
    }

    func updateMagnification() {
        // Show all data and force the inclusion of 0, 0 when magnification is 1.0
        if magnification == 1.0 {
            self.visibleStartIndex = 0
            self.visibleEndIndex = dataPoints.count
            self.visibleXRange = self.xRange
            self.visibleYRange = self.yRange
            return
        }

        // Update data visiblity when magnification != 1.0
        let magnificationOffset: CGFloat = ((self.xRange.1 - self.xRange.0) / self.magnification) / 2
        let midPoint: CGFloat = (self.visibleXRange.1 + self.visibleXRange.0) / 2
        // Don't extend beyond the range of the x values in either direction
        let xStart = max(self.xRange.0, midPoint - magnificationOffset)
        let xEnd = min(self.xRange.1, midPoint + magnificationOffset)
        guard let startIndex = dataPoints.firstIndex(where: { $0.x >= xStart }),
              let endIndex = dataPoints.lastIndex(where: { $0.x <= xEnd }) else {
            return
        }
        self.visibleStartIndex = startIndex
        self.visibleEndIndex = endIndex
        self.visibleXRange = (xStart, xEnd)
        self.updateVisibleYRange()
    }

    func applyPan(_ pan: CGFloat) {
        self.visibleXRange = (self.visibleXRange.0 + pan, self.visibleXRange.1 + pan)
        guard let startIndex = dataPoints.firstIndex(where: { $0.x >= self.visibleXRange.0 }),
              let endIndex = dataPoints.lastIndex(where: { $0.x <= self.visibleXRange.1 }) else {
            return
        }
        self.visibleStartIndex = startIndex
        self.visibleEndIndex = endIndex
        self.updateVisibleYRange()
    }

    func updateVisibleYRange() {
        self.visibleYRange = (dataPoints[visibleStartIndex...visibleEndIndex].min(by: { $0.y < $1.y })?.y ?? self.yRange.0,
                              dataPoints[visibleStartIndex...visibleEndIndex].max(by: { $0.y < $1.y })?.y ?? self.yRange.1)
        let minimumYRange = (self.yRange.1 - self.yRange.0) / 100
        if (self.visibleYRange.1 - self.visibleYRange.0) < minimumYRange {
            let yRangeMidpoint = (self.visibleYRange.0 + self.visibleYRange.1) / 2
            self.visibleYRange = (yRangeMidpoint - minimumYRange / 2, yRangeMidpoint + minimumYRange / 2)
        }
    }
}

struct DynamicGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let x = vDSP.ramp(withInitialValue: 0.0, increment: Double.pi / 45.0, count: 180)
        let x2 = vDSP.ramp(withInitialValue: 4 * Double.pi, increment: Double.pi / 45.0, count: 90)
        let xInt1 = Array(stride(from: 0.0, to: 25.0, by: 1.0))
        let xInt2 = Array(stride(from: 25.0, to: 75.0, by: 1.0))
        let xInt3 = Array(stride(from: 75.0, to: 100.0, by: 1.0))
        let yInt1 = Array(0..<25)
        let yInt2 = Array(repeating: 25, count: 50)
        let yInt3 = Array(Array(0..<25).reversed())
        let y = x.map({3 + sin($0)})
        // TODO: Zooming in on this data produces 6 y axis labels instead of the usual 5
        let y2 = x.map({sin($0)})
        let y3 = x.map({1 + sin($0)})
        let y4 = x2.map({ 1 + sin($0) })
        DynamicGraphView(x: x, y: y, showZones: true)
        DynamicGraphView(data: [(x, y), (x2, y4)], showZones: true, zoneMaximum: 3.0)
        DynamicGraphView(x: xInt1 + xInt2 + xInt3, y: yInt1 + yInt2 + yInt3, color: Color.purple)
        DynamicGraphView(data: [(xInt1, yInt1), (xInt2, yInt2), (xInt3, yInt3)], colors: [Color.purple, Color.orange])

        // TODO: Can't pan in a ScrollView
        ScrollView {
            LazyVStack {
                DynamicGraphView(x: x, y: y3, showZones: true)
                    .padding()
                DynamicGraphView(x: x, y: y)
                    .padding()
                DynamicGraphView(x: x, y: y2)
                    .padding()
            }
        }
    }
}
