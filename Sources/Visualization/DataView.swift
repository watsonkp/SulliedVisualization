import SwiftUI

struct DataView: View {
    let width: CGFloat
    let height: CGFloat
    let positions: [CGPoint]

    init(width: CGFloat, height: CGFloat, minX: Double, maxX: Double, minY: Double, maxY: Double, xs: [Double], ys: [Int]) {
        self.width = width
        self.height = height

        // Use the first n data elements where n is the length of the shortest dimension
        let count = xs.count > ys.count ? xs.count : ys.count

        var positions = Array(repeating: CGPoint(x: 0, y: 0), count: count)
        for i in 0..<count {
            let y = Int(height) - Int(Double(height - 50) * (Double(ys[i]) - minY) / (maxY - minY))
            let x = Int(Double(width) * (xs[i] - minX) / (maxX - minX))
            positions[i] = CGPoint(x: x, y: y)
        }
        self.positions = positions
    }

    init(width: CGFloat, height: CGFloat, minX: Double, maxX: Double, minY: Double, maxY: Double, xs: [Double], ys: [Double]) {
        self.width = width
        self.height = height

        // Use the first n data elements where n is the length of the shortest dimension
        let count = xs.count > ys.count ? xs.count : ys.count

        var positions = Array(repeating: CGPoint(x: 0, y: 0), count: count)
        for i in 0..<count {
            let y = Int(height) - Int(Double(height - 50) * (ys[i] - minY) / (maxY - minY))
            let x = Int(Double(width) * (xs[i] - minX) / (maxX - minX))
            positions[i] = CGPoint(x: x, y: y)
        }
        self.positions = positions
    }

    var body: some View {
        ZStack {
            ForEach (positions.indices) { index in
                Circle()
                    .path(in: CGRect(origin: positions[index], size: CGSize(width: 3, height: 3)))
                    .fill(Color.blue)
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
