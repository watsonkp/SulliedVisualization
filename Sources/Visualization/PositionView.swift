import SwiftUI

public struct PositionView: View {
    let x: [Double]?
    let y: [Double]?
    let color: Color?
    let xRange: (Double, Double)
    let yRange: (Double, Double)

    let xs: [[Double]]?
    let ys: [[Double]]?
    var colors: [Color]?

    public var body: some View {
        GeometryReader { proxy in
            if proxy.size.width == 0.0 || proxy.size.height == 0.0 {
                EmptyView()
            } else if let xData = x, let yData = y {
                DataView(width: proxy.size.width, height: proxy.size.height, minX: xRange.0, maxX: xRange.1, minY: yRange.0, maxY: yRange.1, xs: xData, ys: yData, color: color!, equalScaling: true)
            } else if let xData = xs, let yData = ys {
                ZStack {
                    ForEach(xData.indices, id: \.self) { i in
                        DataView(width: proxy.size.width, height: proxy.size.height, minX: xRange.0, maxX: xRange.1, minY: yRange.0, maxY: yRange.1, xs: xData[i], ys: yData[i], color: colors![i], equalScaling: true)
                    }
                }
            }
        }
    }

    public init(xs: [Double], ys: [Double], color: Color = Color.blue) {
        let projections = Location.project(latitude: ys, longitude: xs)
        self.x = projections.0
        self.y = projections.1
        self.color = color
        self.colors = nil

        if let xMin = x?.min(),
           let xMax = x?.max() {
            self.xRange = (xMin, xMax)
        } else {
            self.xRange = (0.0, 1.0)
        }

        if let yMin = y?.min(),
           let yMax = y?.max() {
            self.yRange = (yMin, yMax)
        } else {
            self.yRange = (0.0, 1.0)
        }

        self.xs = nil
        self.ys = nil
    }

    public init(paths: [([Double], [Double])], colors: [Color] = [Color.blue]) {
        let projections = paths.map { Location.project(latitude: $0.1, longitude: $0.0) }
        self.xs = projections.map { $0.0 }
        self.ys = projections.map { $0.1 }

        self.colors = colors
        while paths.count > self.colors!.count {
            self.colors!.append(contentsOf: colors)
        }

        if let xMin = (xs?.compactMap { $0.min() })?.min(),
           let xMax = (xs?.compactMap { $0.max() })?.max() {
            self.xRange = (xMin, xMax)
        } else {
            self.xRange = (0.0, 1.0)
        }

        if let yMin = (ys?.compactMap { $0.min() })?.min(),
           let yMax = (ys?.compactMap { $0.max() })?.max() {
            self.yRange = (yMin, yMax)
        } else {
            self.yRange = (0.0, 1.0)
        }

        self.x = nil
        self.y = nil
        self.color = nil
    }
}

struct PositionView_Previews: PreviewProvider {
    static var previews: some View {
        // Load test data for a single circuit
        let circuitRecords: [Record] = load("2021-06-29-13-20-23.json")
        let circuitPath = parseLocations(circuitRecords)

        // Preview
        PositionView(xs: circuitPath.0, ys: circuitPath.1)

        // Load test data for three splits
        let splitRecords: [Record] = load("2021-07-03-13-56-44.json")
        let splitPaths = parseAllLocations(splitRecords)
        PositionView(paths: splitPaths, colors: [Color.red, Color.green, Color.blue])
    }
}
