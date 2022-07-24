import SwiftUI

struct DataView: View {
    let width: CGFloat
    let height: CGFloat
    let positions: [CGPoint]
    let color: Color

    enum FunctionType {
        case wellDefined
        case multivalued
    }

    struct Position : Hashable {
        let x: Int
        let y: Int
    }

    init(width: CGFloat, height: CGFloat, minX: Double, maxX: Double, minY: Double, maxY: Double, xs: [Double], ys: [Int], color: Color = Color.blue, fType: FunctionType = .wellDefined) {
        self.width = width
        self.height = height
        self.color = color

        // Use the first n data elements where n is the length of the shortest dimension
        switch fType {
        case .wellDefined:
            var pixels: [Int: [Int]] = [:]
            for (index, value) in xs.enumerated() {
                let x = Int(Double(width) * (value - minX) / (maxX - minX))
                if var pixel = pixels[x] {
                    pixel.append(ys[index])
                    pixels[x] = pixel
                } else {
                    pixels[x] = [ys[index]]
                }
            }

            self.positions = pixels.map { (key, value) in
                let mean = Double(value.reduce(0, { $0 + $1 })) / Double(value.count)
                return CGPoint(x: key, y: Int(height) - Int(Double(height) * (mean - minY) / (maxY - minY)))
            }
        case .multivalued:
            var pixels = Set<Position>()
            for (index, value) in xs.enumerated() {
                let x = Int(Double(width) * (value - minX) / (maxX - minX))
                let y = Int(height) - Int(Double(height) * (Double(ys[index]) - minY) / (maxY - minY))
                pixels.insert(Position(x: x, y: y))
            }
            self.positions = pixels.map { CGPoint(x: $0.x, y: $0.y) }
        }
    }

    init(width: CGFloat, height: CGFloat, minX: Double, maxX: Double, minY: Double, maxY: Double, xs: [Double], ys: [Double], color: Color = Color.blue, equalScaling: Bool = false) {
        self.width = width
        self.height = height
        self.color = color

        // Use the first n data elements where n is the length of the shortest dimension
        let count = xs.count > ys.count ? xs.count : ys.count

        var pixels = Set<Position>()
        if equalScaling {
            // When equalScaling is set to true the x and y values are scaled with the same ratio
            var xScaling = Double(width) / (maxX - minX)
            if xScaling == Double.infinity {
                // CRASH if maxX == minX etc because it goes to infinity. Example: no movement in location data.
                xScaling = Double(width) / 10
            }
            var yScaling = Double(height) / (maxY - minY)
            if yScaling == Double.infinity {
                // CRASH if maxY == minY etc because it goes to infinity. Example: no movement in location data.
                yScaling = Double(height) / 10
            }
            let scaling = xScaling < yScaling ? xScaling : yScaling
            // Calculate offsets to center data horizontally and vertically
            let xOffset = (Double(width) - scaling * (maxX - minX)) / 2
            let yOffset = (Double(height) - scaling * (maxY - minY)) / 2

            for i in 0..<count {
                let x = Int(xOffset) + Int(scaling * (xs[i] - minX))
                let y = Int(Double(height) - yOffset) - Int(scaling * (ys[i] - minY))
                pixels.insert(Position(x: x, y: y))
            }
        } else {
            // When equalScaling is set to false the x and y values are scaled independently to fill the frame
            for i in 0..<count {
                // TODO: CRASH if maxX == minX etc because it goes to infinity. Example: no movement in location data.
                let x = Int(Double(width) * (xs[i] - minX) / (maxX - minX))
                let y = Int(height) - Int(Double(height) * (ys[i] - minY) / (maxY - minY))
                pixels.insert(Position(x: x, y: y))
            }
        }
        self.positions = pixels.map { CGPoint(x: $0.x, y: $0.y) }
    }

    var body: some View {
        ZStack {
            ForEach (positions.indices) { index in
                Circle()
                    .path(in: CGRect(origin: positions[index], size: CGSize(width: 3, height: 3)))
                    .fill(self.color)
            }
        }.frame(height: height)
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        let records: [Record] = load("2021-06-29-13-20-23.json")
        let data = parse(records)
        GeometryReader { proxy in
            DataView(width: proxy.size.width, height: 350, minX: 0, maxX: 40 * 60, minY: 80, maxY: 200, xs: data.0, ys: data.1)
        }
    }
}
