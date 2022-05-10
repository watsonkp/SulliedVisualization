import SwiftUI
import Accelerate

struct AxisOrigin: View {
    let placeholder: String
    var body: some View {
        VStack {
            Text(placeholder)
                .monospacedDigit()
                .padding()
                .opacity(0.0)
        }
    }

    init(positivePositions: Int, negativePositions: Int, negative: Bool = false) {
        var s = negative ? "-" : ""
        s.reserveCapacity(positivePositions + negativePositions + 1)
        s.append(String(repeating: "0", count: positivePositions))
        if negativePositions > 0 {
            s.append(".")
            s.append(String(repeating: "0", count: negativePositions))
        }
        self.placeholder = s
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

struct YAxis: View {
    let labels: [String]
    var body: some View {
        VStack(spacing: 0) {
            ForEach(labels, id: \.self) { label in
                YAxisLabelView(label: label)
            }
        }
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
    let xDimension: Dimension?
    let yDimension: Dimension?
    let xDataUnit: Unit?
    let yDataUnit: Unit?
    let readableXRange: ReadableRangeProtocol
    let readableYRange: ReadableRangeProtocol
    let yVisibleDataRange: (CGFloat, CGFloat)
    var visibleStartIndex: Int {
        get {
            if zoom * partialZoom == 1.0 {
                return 0
            }
            let width = (xRange.1 - xRange.0) / (zoom * partialZoom)
            let xStart = pan + partialPan - width / 2
            return dataPoints.firstIndex(where: { $0.x >= xStart }) ?? 0
        }
    }
    var visibleEndIndex: Int {
        get {
            if zoom * partialZoom == 1.0 {
                return dataPoints.count
            }
            let width = (xRange.1 - xRange.0) / (zoom * partialZoom)
            let xStart = pan + partialPan - width / 2
            let xEnd = xStart + (xRange.1 - xRange.0) / (zoom * partialZoom)
            return dataPoints.lastIndex(where: { $0.x <= xEnd }) ?? dataPoints.count
        }
    }
    var visibleXRange: (CGFloat, CGFloat) {
        get {
            if zoom * partialZoom == 1.0 {
                return (readableXRange.start,
                        readableXRange.end)
            }
            let width = (xRange.1 - xRange.0) / (zoom * partialZoom)
            return (pan + partialPan - width / 2, pan + partialPan + width / 2)
        }
    }
    var xLabels: [String] {
        get {
            if zoom * partialZoom == 1.0 {
                return readableXRange.labels
            }
            let xIncrement = (self.visibleXRange.1 - self.visibleXRange.0) / CGFloat(readableXRange.count)
            return stride(from: self.visibleXRange.0, to: self.visibleXRange.1, by: xIncrement)
                .map({ String(format: "%.1f", $0) })
        }
    }
    let showZones: Bool
    let zoneMaximum: Double?
    @State var isInteracting = false
    @GestureState private var partialZoom: CGFloat = 1.0
    @State var zoom: CGFloat = 1.0
    @GestureState private var partialPan: CGFloat = 0.0
    @State private var pan: CGFloat = 0.0

    public var body: some View {
        StaticGraphView(data: dataPoints,
                        showZones: showZones,
                        zoneMaximum: zoneMaximum,
                        xLabelCount: [readableXRange.count],
                        yLabelCount: [readableYRange.count],
                        xDimension: xDimension,
                        yDimension: yDimension,
                        xDataUnit: xDataUnit,
                        yDataUnit: yDataUnit)
        .border(Color.accentColor)
        .gesture(TapGesture().onEnded({ value in
            isInteracting = true
        }))
        .fullScreenCover(isPresented: $isInteracting, content: {
            VStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        YAxis(labels: readableYRange.labels.reversed())
                        GeometryReader { proxy in
                            ZStack {
                                DataViewV2(data: dataPoints[visibleStartIndex..<visibleEndIndex],
                                           xRange: visibleXRange,
                                           yRange: yVisibleDataRange,
                                           showZones: showZones,
                                           zoneMaximum: zoneMaximum)
                                GridLineOverlayView(xTicks: readableXRange.count, yTicks: readableYRange.count)
                            }
                            // DragGesture needs to precede MagnificationGesture or its updating() callback will not be called
                                .gesture(DragGesture()
                                    .updating($partialPan) { value, state, transaction in
                                        let width = (xRange.1 - xRange.0) / zoom
                                        state = -1 * width * (value.location.x - value.startLocation.x) / proxy.size.width
                                    }
                                    .onEnded { value in
                                        // Show all data and force the inclusion of 0, 0 when magnification is 1.0
                                        if zoom == 1.0 {
                                            pan = (xRange.1 - xRange.0) / 2
                                            return
                                        }
                                        let width = (xRange.1 - xRange.0) / zoom
                                        // Translate the data in the opposite direction of the drag aka "Natural scrolling".
                                        var translation = -1 * width * (value.location.x - value.startLocation.x) / proxy.size.width
                                        // Limit drags to the right by the remaining off screen range to the left
                                        translation = max(-1 * (pan - width / 2 - xRange.0), translation)
                                        // Limit drags to the left by the remaining off screen range to the right
                                        translation = min(xRange.1 - (pan + width / 2), translation)
                                        pan += translation
                                    })
                                .gesture(MagnificationGesture()
                                         // TODO: Handle the initial zoom from the readable range smoothly
                                         // TODO: It seems like magnification can be infinity.
                                         // TODO: Handle large magnifications with exponential decay and a hard limit? min(10.0, Double.infinity) works.
                                    .updating($partialZoom) { value, state, transaction in
                                        state = value
                                    }
                                    .onEnded { value in
                                        // Set a lower limit of 1.0 for magnification.
                                        if value * zoom <= 1.0 {
                                            zoom = 1.0
                                            pan = (xRange.1 - xRange.0) / 2
                                            return
                                        }
                                        zoom = value * zoom
                                        let width = (xRange.1 - xRange.0) / zoom
                                        let leftLimit = xRange.0 + width / 2
                                        let rightLimit = xRange.1 - width / 2
                                        // Reducing zoom to an ending value above 1.0 can reveal empty x range above or below the limits. Update pan to compensate.
                                        if pan < leftLimit || pan > rightLimit {
                                            var resetPan = max(leftLimit, pan)
                                            resetPan = min(rightLimit, resetPan)
                                            pan = resetPan
                                        }
                                })
                        }
                    }
                    HStack(spacing: 0) {
                        AxisOrigin(positivePositions: readableYRange.integerDigits,
                                   negativePositions: readableYRange.fractionalDigits,
                                   negative: readableYRange.start < 0)
                        HStack(spacing: 0) {
                            // Need to restrict the labels to the expected range because floating point division can be inconsistent.
                            // 4.0 produced 4 labels consistently, but 3.0 sometimes produced 3 and sometimes 4 depending on the pan.
                            ForEach(xLabels[0..<readableXRange.count], id: \.self) { label in
                                XAxisLabelView(label: label)
                            }
                        }.frame(maxWidth: .infinity)
                    }
                    Text("Dimensions: \(readableYRange.labelFactorLabel) by \(readableXRange.labelFactorLabel)")
                }.padding()
                Button(action: { isInteracting = false}) {
                    Text("Dismiss")
                }
        }
        })
    }

    // Plot floating point data
    public init(x: [Double], y: [Double], color: Color = Color.accentColor, showZones: Bool = false, zoneMaximum: Double? = nil, xLabelCount: [Int] = [3, 4], yLabelCount: [Int] = [4, 5, 6], xDimension: Dimension? = nil, yDimension: Dimension? = nil, xDataUnit: Dimension? = nil, yDataUnit: Dimension? = nil) {
        self.colors = [color]
        self.dataPoints = zip(x, y).filter({ $0.0.isFinite && $0.1.isFinite }).map({ DataPoint(x: $0.0, y: $0.1, color: color) })
        // Include x=0 and use a range of [0.0, 1.0] when min and max fail due to missing data
        self.xRange = (CGFloat(x.min() ?? 0.0), CGFloat(x.max() ?? 1.0))
        let yRange = (CGFloat(y.min() ?? 0.0), CGFloat(y.max() ?? 1.0))

        // Use a range of [0.0, 1.0] when min and max fail due to missing data
        switch xDimension {
        case let duration as UnitDuration:
            self.readableXRange = ReadableDurationRange(lower: Measurement(value: xRange.0, unit: duration), upper: Measurement(value: xRange.1, unit: duration))
        default:
            self.readableXRange = ReadableRange(lower: xRange.0, upper: xRange.1, count: xLabelCount)
        }
        self.xDimension = xDimension
        self.xDataUnit = xDataUnit

        switch yDimension {
        case let duration as UnitDuration:
            self.readableYRange = ReadableDurationRange(lower: Measurement(value: min(0.0, yRange.0), unit: duration),
                                                        upper: Measurement(value: yRange.1, unit: duration))
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
            self.readableYRange = ReadableRange(lower: min(0.0, yRange.0), upper: yRange.1, count: yLabelCount)
        }

        // Scale readable y range start and end when the label unit differs from the data unit
        if let labelUnit = yDimension, let dataUnit = yDataUnit as? Dimension {
            self.yVisibleDataRange = (CGFloat(Measurement(value: readableYRange.start, unit: labelUnit).converted(to: dataUnit).value),
                                      CGFloat(Measurement(value: readableYRange.end, unit: labelUnit).converted(to: dataUnit).value))
        } else {
            self.yVisibleDataRange = (readableYRange.start, readableYRange.end)
        }

        self.yDimension = yDimension
        self.yDataUnit = yDataUnit

        self.showZones = showZones
        self.zoneMaximum = zoneMaximum
        // TODO: Avoid setting state variables in init. Defeats the purpose.
        self.pan = (xRange.1 - xRange.0) / 2
    }

    // Plot multiple series of floating point data
    public init(data: [([Double], [Double])], colors: [Color] = [Color.red, Color.green, Color.blue], showZones: Bool = false, zoneMaximum: Double? = nil, xLabelCount: [Int] = [3, 4], yLabelCount: [Int] = [4, 5, 6], xDimension: Dimension? = nil, yDimension: Dimension? = nil, xDataUnit: Dimension? = nil, yDataUnit: Dimension? = nil) {
        // Repeat the colors array if it is shorter than the data array.
        // Check for an empty colors array
        self.colors = Array(Array(repeating: colors.count > 0 ? colors : [Color.red, Color.green, Color.blue],
                                  count: 1 + data.count / colors.count)
            .reduce(into: [Color](), { $0.append(contentsOf: $1) })[0..<data.count])
        self.dataPoints = DynamicGraphView.createDataPoints(data: data, colors: self.colors)
        // Use a range of [0.0, 1.0] when min and max fail due to missing data
        self.xRange = (self.dataPoints.min(by: { $0.x < $1.x })?.x ?? 0.0,
                       self.dataPoints.max(by: { $0.x < $1.x })?.x ?? 1.0)
        let yRange = (self.dataPoints.min(by: { $0.y < $1.y })?.y ?? 0.0,
                       self.dataPoints.max(by: { $0.y < $1.y })?.y ?? 1.0)

        // Include y=0 and use a range of [0.0, 1.0] when min and max fail due to missing data
        let yRangeMax = self.dataPoints.max(by: { $0.y < $1.y })?.y ?? 1.0
        switch xDimension {
        case let duration as UnitDuration:
            self.readableXRange = ReadableDurationRange(lower: Measurement(value: xRange.0, unit: duration), upper: Measurement(value: xRange.1, unit: duration))
        default:
            self.readableXRange = ReadableRange(lower: xRange.0, upper: xRange.1, count: xLabelCount)
        }
        self.xDimension = xDimension
        self.xDataUnit = xDataUnit

        switch yDimension {
        case let duration as UnitDuration:
            self.readableYRange = ReadableDurationRange(lower: Measurement(value: min(0.0, yRange.0), unit: duration),
                                                        upper: Measurement(value: yRangeMax, unit: duration))
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
            self.readableYRange = ReadableRange(lower: min(0.0, self.dataPoints.min(by: { $0.y < $1.y })?.y ?? 0.0), upper: yRangeMax, count: yLabelCount)
        }

        // Scale readable y range start and end when the label unit differs from the data unit
        if let labelUnit = yDimension, let dataUnit = yDataUnit as? Dimension {
            self.yVisibleDataRange = (CGFloat(Measurement(value: readableYRange.start, unit: labelUnit).converted(to: dataUnit).value),
                                      CGFloat(Measurement(value: readableYRange.end, unit: labelUnit).converted(to: dataUnit).value))
        } else {
            self.yVisibleDataRange = (readableYRange.start, readableYRange.end)
        }

        self.yDimension = yDimension
        self.yDataUnit = yDataUnit

        self.showZones = showZones
        self.zoneMaximum = zoneMaximum
        self.pan = (xRange.1 - xRange.0) / 2
    }

    // Plot integer data
    public init(x: [Double], y: [Int], color: Color = Color.accentColor, showZones: Bool = false, zoneMaximum: Double? = nil, xLabelCount: [Int] = [3, 4], yLabelCount: [Int] = [4, 5, 6], xDimension: Dimension? = nil, yDimension: Dimension? = nil) {
        self.init(x: x, y: y.map({ CGFloat($0) }),
                  color: color,
                  showZones: showZones,
                  zoneMaximum: zoneMaximum,
                  xLabelCount: xLabelCount,
                  yLabelCount: yLabelCount,
                  xDimension: xDimension,
                  yDimension: yDimension)
    }

    // Plot multiple series of integer data
    public init(data: [([Double], [Int])], colors: [Color] = [Color.red, Color.green, Color.blue], showZones: Bool = false, zoneMaximum: Double? = nil, xLabelCount: [Int] = [3, 4], yLabelCount: [Int] = [4, 5, 6], xDimension: Dimension? = nil, yDimension: Dimension? = nil) {
        self.init(data: data.map({ ($0.0, $0.1.map({ CGFloat($0) })) }),
                  colors: colors,
                  showZones: showZones,
                  zoneMaximum: zoneMaximum,
                  xLabelCount: xLabelCount,
                  yLabelCount: yLabelCount,
                  xDimension: xDimension,
                  yDimension: yDimension)
    }

    private static func createDataPoints(data: [([Double], [Double])], colors: [Color]) -> [DataPoint] {
        var dataPoints = [DataPoint]()
        for ((x, y), color) in zip(data, colors) {
            dataPoints.append(contentsOf: zip(x, y).filter({ $0.0.isFinite && $0.1.isFinite }).map({ DataPoint(x: $0.0, y: $0.1, color: color) }))
        }
        return dataPoints
    }

    private static func createZones(zoneMax: CGFloat) -> [Zone] {
        return zip(stride(from: 100.0, to: 50.0, by: -10.0).map({ zoneMax * $0 / 100.0}),
                         [Color.red, Color.yellow, Color.green, Color.blue, Color.gray])
        .map({ Zone(minimum: $0.0 - zoneMax / 10.0, maximum: $0.0, color: $0.1) })
    }
}

struct DynamicGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let x = vDSP.ramp(withInitialValue: 0.0, increment: Double.pi / 45.0, count: 180)
        let x2 = vDSP.ramp(withInitialValue: 4 * Double.pi, increment: Double.pi / 45.0, count: 90)
        let x3 = Array(stride(from: 0.0, to: 7000, by: 10.0))
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
        let y5 = x.map({2 + 1.3 * sin($0)})
        let y6 = x3.map({3000 + 2500 * sin($0 / 10 * Double.pi / 180)})
        let y7 = x3.map({317.0 / 60 + 32 / 60.0 * sin($0 / 10 * Double.pi / 180)})
        DynamicGraphView(x: x, y: y, showZones: true)
        DynamicGraphView(data: [(x, y), (x2, y4)], showZones: true, zoneMaximum: 4.0)
        DynamicGraphView(x: x, y: y5)
        DynamicGraphView(x: xInt1 + xInt2 + xInt3, y: yInt1 + yInt2 + yInt3, color: Color.purple)
        DynamicGraphView(data: [(xInt1, yInt1), (xInt2, yInt2), (xInt3, yInt3)], colors: [Color.purple, Color.orange])
        DynamicGraphView(x: x3, y: y6, xDimension: UnitDuration.seconds)
        DynamicGraphView(x: x3, y: y7, xDimension: UnitDuration.seconds, yDimension: UnitPace.minutesPerKilometer, yDataUnit: UnitPace.minutesPerKilometer)
        DynamicGraphView(x: x3, y: y7, xDimension: UnitDuration.seconds, yDimension: UnitPace.minutesPerMile, yDataUnit: UnitPace.minutesPerKilometer)


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
