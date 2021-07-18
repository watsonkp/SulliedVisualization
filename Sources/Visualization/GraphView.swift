import SwiftUI

public struct GraphView: View {
    let x: [Double]
    let y: [Int]
    let minX: Double
    let maxX: Double
    let minY: Int
    let maxY: Int

    let xAxis: TimeAxis
    let yAxis: ValueAxis

    public var body: some View {
        GeometryReader { proxy in
            VStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                HStack(spacing: 0) {
                    // Y-Axis
                    yAxis.view(height: proxy.size.height)
                        .frame(width: 50)
                    // Data area
                    ZStack {
                        GridLineView(width: proxy.size.width, height: proxy.size.height - 50, count: 6)
                        DataView(width: proxy.size.width - 50, height: proxy.size.height - 50, minX: 0, maxX: 40 * 60, minY: 80, maxY: 200, xs: x, ys: y)
                    }
                }
                .frame(height: proxy.size.height - 50)

                // X-Axis
                xAxis.view(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }

    public init(x: [Double], y: [Int]) {
        self.x = x
        self.y = y

        self.minX = x.min()!
        self.maxX = x.max()!
        self.minY = y.min()!
        self.maxY = y.max()!

        self.xAxis = TimeAxis(min: self.minX, max: self.maxX, count: 5)
        self.yAxis = ValueAxis(min: self.minY, max: self.maxY, count: 5)
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        let records: [Record] = load("2021-06-29-13-20-23.json")
        let data = parse(records)
        GraphView(x: data.0, y: data.1)
    }
}
