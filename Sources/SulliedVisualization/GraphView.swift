import SwiftUI

public struct GraphView: View {
    let x: [Double]?
    let y: [Int]?
    let xs: [[Double]]?
    let ys: [[Int]]?
    let minX: Double
    let maxX: Double
    let minY: Int
    let maxY: Int
    let color: Color?
    var colors: [Color]?
    let showZones: Bool
    let zoneMax: Int

    let xAxis: TimeAxis
    let yAxis: ValueAxis

    public var body: some View {
        GeometryReader { proxy in
            if proxy.size.width == 0.0 || proxy.size.height == 0.0 {
                EmptyView()
            } else if (x != nil && y != nil) || (xs != nil && ys != nil) {
                VStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                    HStack(spacing: 0) {
                        // Y-Axis
                        yAxis.view(height: proxy.size.height - 50)
                            .frame(width: 50, height: proxy.size.height - 50)
                        // Data area
                        ZStack {
                            // Optionally color regions of the graph in relation to a maximum value
                            if showZones {
                                ZoneView(width: proxy.size.width - 50, height: proxy.size.height - 50, max: zoneMax, valueRange: (Int(yAxis.minimum), Int(yAxis.maximum)))
                            }
                            GridLineView(width: proxy.size.width - 50, height: proxy.size.height - 50, count: 2 * (yAxis.labels.count - 1))
                            if let x = x, let y = y {
                                DataView(width: proxy.size.width - 50, height: proxy.size.height - 50, minX: 0, maxX: 60.0 * xAxis.maximum, minY: yAxis.minimum, maxY: yAxis.maximum, xs: x, ys: y, color: color!)
                            } else if let xs = xs, let ys = ys {
                                ForEach(xs.indices, id: \.self) { index in
                                    DataView(width: proxy.size.width - 50, height: proxy.size.height - 50, minX: 0, maxX: 60.0 * xAxis.maximum, minY: yAxis.minimum, maxY: yAxis.maximum, xs: xs[index], ys: ys[index], color: colors![index])
                                }
                            }
                        }
                        .frame(width: proxy.size.width - 50)
                    }
                    .frame(height: proxy.size.height - 50)

                    // X-Axis
                    HStack {
                        Spacer().frame(width: 50, height: 50)
                        xAxis.view(width: proxy.size.width - 50, height: 50)
                    }
                }
            } else {
                ErrorView(message: "No data", width: proxy.size.width, height: proxy.size.height)
            }
        }
    }

    public init(x: [Double], y: [Int], color: Color = Color.primary, showZones: Bool = false, zoneMax: Int = 220) {
        // Check for empty arrays of data
        if x.count == 0 || y.count == 0 {
            self.x = nil
            self.y = nil
        } else {
            self.x = x
            self.y = y
        }

        // Set minimum and maximum values for each axis
        if let minX = x.min(), let maxX = x.max(), let minY = y.min(), let maxY = y.max() {
            self.minX = minX
            self.maxX = maxX
            self.minY = minY
            self.maxY = maxY
        } else {
            // Set safe default minimum and maximum values when data arrays are empty
            self.minX = 0.0
            self.maxX = 1.0
            self.minY = 0
            self.maxY = 1
        }

        self.color = color

        self.xAxis = TimeAxis(min: self.minX, max: self.maxX, count: 5)
        self.yAxis = ValueAxis(min: self.minY, max: self.maxY, count: 5)

        self.xs = nil
        self.ys = nil
        self.colors = nil

        self.showZones = showZones
        self.zoneMax = zoneMax
    }

    public init(data: [([Double], [Int])], colors: [Color] = [Color.primary], showZones: Bool = false, zoneMax: Int = 220) {
        // Check for and omit empty arrays of data
        let xs = data.compactMap({ $0.0.count > 0 ? $0.0 : nil })
        let ys = data.compactMap({ $0.1.count > 0 ? $0.1 : nil })

        if xs.count == 0 || ys.count == 0 {
            self.xs = nil
            self.ys = nil
        } else {
            self.xs = xs
            self.ys = ys
        }

        // Set minimum and maximum values for each axis
        if let minX = xs.compactMap({$0.min()}).min(),
           let maxX = xs.compactMap({$0.max()}).max(),
           let minY = ys.compactMap({$0.min()}).min(),
           let maxY = ys.compactMap({$0.max()}).max() {
            self.minX = minX
            self.maxX = maxX
            self.minY = minY
            self.maxY = maxY
        } else {
            // Set safe default minimum and maximum values when data arrays are empty
            self.minX = 0.0
            self.maxX = 1.0
            self.minY = 0
            self.maxY = 1
        }

        var colorList = colors
        while xs.count > colorList.count {
            colorList.append(contentsOf: colors)
        }
        self.colors = colorList

        self.xAxis = TimeAxis(min: self.minX, max: self.maxX, count: 5)
        self.yAxis = ValueAxis(min: self.minY, max: self.maxY, count: 5)

        self.x = nil
        self.y = nil
        self.color = nil

        self.showZones = showZones
        self.zoneMax = zoneMax
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        let records: [Record] = load("2021-06-29-13-20-23.json")
        let data = parse(records)
        GraphView(x: data.0, y: data.1, color: Color.primary, showZones: true)
        GraphView(x: data.0, y: data.1, color: Color.primary, showZones: true, zoneMax: 192)
        GraphView(x: data.0, y: data.1, color: Color.primary, showZones: true, zoneMax: 192)
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)

        let splitRecords: [Record] = load("2021-07-03-13-56-44.json")
        let splitPaths = parseAll(splitRecords)
        GraphView(data: splitPaths, colors: [Color.red, Color.green, Color.blue])
        GraphView(data: splitPaths, colors: [Color.primary, Color.purple, Color.orange], showZones: true, zoneMax: 192)
        GraphView(x: [], y: [])
        GraphView(data: [([], [])])
    }
}
