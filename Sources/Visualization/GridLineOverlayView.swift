import SwiftUI

struct GridLineOverlayView: View {
    let xTicks: Int
    let yTicks: Int
    var body: some View {
        Canvas { context, size in
            // Y-axis ticks
            context.stroke(Path {
                for increment in Array(stride(from: size.height, to: 0.0, by: -1 * size.height / CGFloat(yTicks)))[1..<yTicks] {
                    $0.move(to: CGPoint(x: 0, y: Int(increment)))
                    $0.addLine(to: CGPoint(x: 10, y: Int(increment)))
                }
            }, with: .color(Color.primary),
                           lineWidth: 2)
            // Axes
            context.stroke(Path {
                // y-axis
                $0.move(to: CGPoint(x: 1, y: 0))
                $0.addLine(to: CGPoint(x: 1, y: Int(size.height)))
                // x-axis
                $0.move(to: CGPoint(x: 0, y: Int(size.height)))
                $0.addLine(to: CGPoint(x: Int(size.width), y: Int(size.height)))
            }, with: .color(Color.primary),
                           lineWidth: 2)
            // X-Axis ticks
            context.stroke(Path {
                for increment in Array(stride(from: 0.0, to: size.width, by: size.width / CGFloat(xTicks)))[1..<xTicks] {
                    $0.move(to: CGPoint(x: Int(increment), y: Int(size.height) - 10))
                    $0.addLine(to: CGPoint(x: Int(increment), y: Int(size.height)))
                }
            }, with: .color(Color.primary),
                           lineWidth: 2)
        }
    }

    init(xTicks: Int = 4, yTicks: Int = 5) {
        self.xTicks = xTicks > 1 ? xTicks : 4
        self.yTicks = yTicks > 1 ? yTicks : 5
    }
}

struct GridLineOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        GridLineOverlayView()
    }
}
