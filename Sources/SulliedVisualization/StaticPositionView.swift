import SwiftUI

struct StaticPositionView: View {
    let points: [DataPoint]
    let xRange: ReadableRange
    let yRange: ReadableRange
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                YAxis(labels: yRange.labels.reversed())
                GeometryReader { proxy in
                    ZStack {
                        GridLineMajorMinorView(xRange: (xRange.start, xRange.end), yRange: (yRange.start, yRange.end))
                        GridLineOverlayView(xTicks: xRange.count, yTicks: yRange.count)
                        Canvas { context, size in
                            let drawableWidth = size.width - 3
                            let drawableHeight = size.height - 3
                            for point in points {
                                let origin = CGPoint(x: Int((point.x - xRange.start) / (xRange.end - xRange.start) * drawableWidth),
                                                     y: Int(drawableHeight - (point.y - yRange.start) / (yRange.end - yRange.start) * drawableHeight))
                                if origin.x < 0.0 || origin.x > drawableWidth || origin.y < 0.0 || origin.y > drawableHeight {
                                    continue
                                }
                                context.fill(Path(ellipseIn: CGRect(origin: origin,
                                                                    size: CGSize(width: 3, height: 3))),
                                             with: .color(point.color))
                            }
                        }
                    }
                }
            }
            HStack(spacing: 0) {
                AxisOrigin(positivePositions: yRange.integerDigits,
                           negativePositions: yRange.fractionalDigits,
                           negative: yRange.start < 0)
                HStack(spacing: 0) {
                    ForEach(xRange.labels, id: \.self) { label in
                        XAxisLabelView(label: label)
                    }
                }.frame(maxWidth: .infinity)
            }
            Text("\(yRange.labelFactorLabel) by \(xRange.labelFactorLabel)")
        }
    }

    init(dataPoints: [DataPoint]) {
        self.points = dataPoints
        let dataXRange = (points.min(by: { $0.x < $1.x })?.x ?? 0.0,
                          points.max(by: { $0.x < $1.x })?.x ?? 1.0)
        let dataYRange = (points.min(by: { $0.y < $1.y })?.y ?? 0.0,
                          points.max(by: { $0.y < $1.y })?.y ?? 1.0)
        self.xRange = ReadableRange(lower: dataXRange.0, upper: dataXRange.1)
        self.yRange = ReadableRange(lower: dataYRange.0, upper: dataYRange.1)
    }

    public init(xs: [Double], ys: [Double], color: Color = Color.blue, isLatLong: Bool = false) {
        self.init(data: [(xs, ys)], colors: [color])
    }

    public init(data rawData: [([Double], [Double])], colors: [Color] = [Color.red, Color.green, Color.blue], isLatLong: Bool = false) {
        var data = rawData
        if isLatLong {
            data = rawData.map({ Location.project(latitude: $0.1, longitude: $0.0) })
        }

        // Repeat the colors array if it is shorter than the data array.
        // Check for an empty colors array
        let paddedColors = Array(repeating: colors.isEmpty ? [Color.red, Color.green, Color.blue] : colors,
                                 count: 1 + data.count / colors.count).joined()
        let points = zip(data, paddedColors).flatMap({ (data, color) -> [DataPoint] in
            zip(data.0, data.1).compactMap({
                guard $0.0.isFinite && $0.1.isFinite else {
                    return nil
                }
                return DataPoint(x: $0.0, y: $0.1, color: color)
            })
        })

        self.init(dataPoints: points)
    }
}

struct StaticPositionView_Previews: PreviewProvider {
    static var previews: some View {
        let xs = [Array(stride(from: 0.0, to: 100.0, by: 5.0)),
                  Array(repeating: 100.0, count: 20),
                  Array(stride(from: 100.0, to: 0.0, by: -5.0)),
                  Array(repeating: 0.0, count: 20)]
        let ys = [Array(repeating: 100.0, count: 20),
                  Array(stride(from: 100.0, to: 0.0, by: -5.0)),
                  Array(repeating: 0.0, count: 20),
                  Array(stride(from: 0.0, to: 100.0, by: 5.0))]

        let xs2: [[Double]] = [Array(stride(from: 0.0, to: 25.0, by: 5.0)),
                   Array(repeating: 25.0, count: 5),
                   Array(stride(from: 25.0, to: 75.0, by: 5.0)),
                   Array(repeating: 75.0, count: 5),
                   Array(stride(from: 75.0, to: 100.0, by: 5.0)),
                   Array(repeating: 100.0, count: 5),
                   Array(stride(from: 100.0, to: 75.0, by: -5.0)),
                   Array(repeating: 75.0, count: 10),
                   Array(stride(from: 75.0, to: 100.0, by: 5.0)),
                   Array(repeating: 100.0, count: 5),
                   Array(stride(from: 100.0, to: 75.0, by: -5.0)),
                   Array(repeating: 75.0, count: 5),
                   Array(stride(from: 75.0, to: 25.0, by: -5.0)),
                   Array(repeating: 25.0, count: 5),
                   Array(stride(from: 25.0, to: 0.0, by: -5.0)),
                   Array(repeating: 0.0, count: 5),
                   Array(stride(from: 0.0, to: 25.0, by: 5.0)),
                   Array(repeating: 25.0, count: 10),
                   Array(stride(from: 25.0, to: 0.0, by: -5.0)),
                   Array(repeating: 0.0, count: 5)]
        let ys2: [[Double]] = [Array(repeating: 100.0, count: 5),
                   Array(stride(from: 100.0, to: 75.0, by: -5.0)),
                   Array(repeating: 75.0, count: 10),
                   Array(stride(from: 75.0, to: 100.0, by: 5.0)),
                   Array(repeating: 100.0, count: 5),
                   Array(stride(from: 100.0, to: 75.0, by: -5.0)),
                   Array(repeating: 75.0, count: 5),
                   Array(stride(from: 75.0, to: 25.0, by: -5.0)),
                   Array(repeating: 25.0, count: 5),
                   Array(stride(from: 25.0, to: 0.0, by: -5.0)),
                   Array(repeating: 0.0, count: 5),
                   Array(stride(from: 0.0, to: 25.0, by: 5.0)),
                   Array(repeating: 25.0, count: 10),
                   Array(stride(from: 25.0, to: 0.0, by: -5.0)),
                   Array(repeating: 0.0, count: 5),
                   Array(stride(from: 0.0, to: 25.0, by: 5.0)),
                   Array(repeating: 25.0, count: 5),
                   Array(stride(from: 25.0, to: 75.0, by: 5.0)),
                   Array(repeating: 75.0, count: 5),
                   Array(stride(from: 75.0, to: 100.0, by: 5.0))]

        StaticPositionView(data: [([Double], [Double])](zip(xs2, ys2)))
        StaticPositionView(data: [([Double], [Double])](zip(xs, ys)))
        let xs4: [[Double]] = [Array(stride(from: 0.000, to: 0.002, by: 0.0001)),
                               Array(stride(from: 0.002, to: 0.004, by: 0.0001))]
        let ys4: [[Double]] = [Array(stride(from: 0.000, to: 0.002, by: 0.0001)),
                               Array(stride(from: 0.002, to: 0.000, by: -0.0001))]
        StaticPositionView(data: [([Double], [Double])](zip(xs4, ys4)))

        let xs3: [[Double]] = [Array(stride(from: 1.380, to: 1.382, by: 0.0001)),
                               Array(stride(from: 1.382, to: 1.384, by: 0.0001))]
        let ys3: [[Double]] = [Array(stride(from: 0.840, to: 0.842, by: 0.0001)),
                               Array(stride(from: 0.842, to: 0.840, by: -0.0001))]
        StaticPositionView(data: [([Double], [Double])](zip(xs3, ys3)))
    }
}
