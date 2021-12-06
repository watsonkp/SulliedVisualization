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
        }
    }

    public init(x: [Double], y: [Int], color: Color = Color.primary, showZones: Bool = false, zoneMax: Int = 220) {
        self.x = x
        self.y = y

        self.minX = x.min()!
        self.maxX = x.max()!
        self.minY = y.min()!
        self.maxY = y.max()!

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
        self.xs = data.map {$0.0}
        self.ys = data.map {$0.1}

        self.minX = data.map({$0.0.min()!}).min()!
        self.maxX = data.map({$0.0.max()!}).max()!
        self.minY = data.map({$0.1.min()!}).min()!
        self.maxY = data.map({$0.1.max()!}).max()!

        self.colors = colors
        while xs!.count > self.colors!.count {
            self.colors!.append(contentsOf: colors)
        }

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
    }
}
