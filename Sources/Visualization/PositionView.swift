import SwiftUI

public struct PositionView: View {
    let x: [Double]
    let y: [Double]
    let xRange: (Double, Double)
    let yRange: (Double, Double)

    public var body: some View {
        GeometryReader { proxy in
            DataView(width: proxy.size.width, height: proxy.size.height, minX: xRange.0, maxX: xRange.1, minY: yRange.0, maxY: yRange.1, xs: x, ys: y)
        }
    }

    public init(xs: [Double], ys: [Double]) {
        let projections = Location.project(latitude: ys, longitude: xs)
        self.x = projections.0
        self.y = projections.1

        xRange = (self.x.min()!, self.x.max()!)
        yRange = (self.y.min()!, self.y.max()!)
    }
}

struct PositionView_Previews: PreviewProvider {
    static var previews: some View {
        // Load test data
        let records: [Record] = load("2021-06-29-13-20-23.json")
        let data = parseLocations(records)

        // Preview
        PositionView(xs: data.0, ys: data.1)
    }
}
