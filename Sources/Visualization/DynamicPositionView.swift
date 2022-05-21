import SwiftUI

public struct DynamicPositionView: View {
    let points: [DataPoint]
    @State var isInteracting = false
    public var body: some View {
        StaticPositionView(dataPoints: points)
            .border(Color.accentColor)
            .gesture(TapGesture().onEnded({ value in
                isInteracting = true
            }))
            .fullScreenCover(isPresented: $isInteracting) {
                VStack {
                    InteractivePositionView(dataPoints: points).padding()
                    Button(action: { isInteracting = false}) {
                        Text("Dismiss")
                    }
                }
            }
    }

    public init(xs: [Double], ys: [Double], color: Color = Color.blue, isLatLong: Bool = false) {
        self.init(data: [(xs, ys)], colors: [color], isLatLong: isLatLong)
    }

    public init(data rawData: [([Double], [Double])], colors: [Color] = [Color.red, Color.green, Color.blue], isLatLong: Bool = false) {
        var data = rawData
        if isLatLong {
            data = rawData.map({ Location.project(latitude: $0.0, longitude: $0.1) })
        }

        // Repeat the colors array if it is shorter than the data array.
        // Check for an empty colors array
        let paddedColors = Array(repeating: colors.isEmpty ? [Color.red, Color.green, Color.blue] : colors,
                                 count: 1 + data.count / colors.count).joined()
        self.points = zip(data, paddedColors).flatMap({ (data, color) -> [DataPoint] in
            zip(data.0, data.1).compactMap({
                guard $0.0.isFinite && $0.1.isFinite else {
                    return nil
                }
                return DataPoint(x: $0.0, y: $0.1, color: color)
            })
        })
    }
}

struct DynamicPositionView_Previews: PreviewProvider {
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

        DynamicPositionView(data: [([Double], [Double])](zip(xs2, ys2)))
        DynamicPositionView(data: [([Double], [Double])](zip(xs, ys)))
    }
}
