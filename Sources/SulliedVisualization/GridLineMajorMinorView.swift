import SwiftUI
import Darwin

struct GridLineMajorMinorView: View {
    // Major grid lines on 10
    // Minor grid lines on 1
    let minorX: [CGFloat]
    let majorX: [CGFloat]
    let minorY: [CGFloat]
    let majorY: [CGFloat]

    var body: some View {
        Canvas { context, size in
            context.opacity = 0.3
            // Major Y
            context.stroke(Path { path in
                for line in majorY {
                    let y = size.height * (1.0 - line)
                    path.move(to: CGPoint(x: 0.0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }, with: .color(Color.primary), style: StrokeStyle(lineWidth: 1, dash: [10, 5]))
            // Minor Y
            // TODO: This isn't quite correct. Panning may cause this number to alternate between 2 and 3.
            // TODO: Panning should not change the presence of minor gridlines. Check it with math. Something like width / increment < 3?
            if majorY.count < 3 {
                context.stroke(Path { path in
                    for line in minorY {
                        let y = size.height * (1.0 - line)
                        path.move(to: CGPoint(x: 0.0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                }, with: .color(Color.accentColor), style: StrokeStyle(lineWidth: 1, dash: [10, 5], dashPhase: 5))
            }
            // Major X
            context.stroke(Path { path in
                for line in majorX {
                    let x = line * size.width
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
            }, with: .color(Color.primary), style: StrokeStyle(lineWidth: 1, dash: [10, 5]))
            // Minor X
            // TODO: This isn't quite correct. Panning may cause this number to alternate between 2 and 3.
            if majorX.count < 3 {
                context.stroke(Path { path in
                    for line in minorX {
                        let x = line * size.width
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                }, with: .color(Color.accentColor), style: StrokeStyle(lineWidth: 1, dash: [10, 5], dashPhase: 5))
            }
        }
    }

    init(xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat)) {
        (self.majorX, self.minorX) = GridLineMajorMinorView.gridLinePositions(lower: xRange.0, upper: xRange.1)
        (self.majorY, self.minorY) = GridLineMajorMinorView.gridLinePositions(lower: yRange.0, upper: yRange.1)
    }

    static func gridLinePositions(lower: CGFloat, upper: CGFloat) -> ([CGFloat], [CGFloat]) {
        // Major
        let range = abs(upper - lower)
        let fractionalOrder = log10(range)
        var order = CGFloat(signOf: fractionalOrder, magnitudeOf: fractionalOrder).rounded(.down)
        var majorIncrement = pow(10.0, order)
        let start = CGFloat(signOf: lower, magnitudeOf: lower / majorIncrement).rounded(.down) * majorIncrement
        var major: [CGFloat] = (0 ..< 11).map({ (start + CGFloat($0) * majorIncrement - lower) / range})
        major = major.filter( { $0 > 0 && $0 < 1})
        if major.isEmpty {
            order = order - 1
            majorIncrement = pow(10.0, order)
            major = (0 ..< 11).map({ (start + CGFloat($0) * majorIncrement - lower) / range})
            major = major.filter( { $0 > 0 && $0 < 1})
        }

        // Minor gridlines are added below major gridlines.
        var minor = [CGFloat]()
        let minorIncrement = 2 * pow(10.0, order - 1)
        for line in major {
            let minorLines = (1 ..< 5).map({ (line * range - CGFloat($0) * minorIncrement) / range})
            minor.append(contentsOf: minorLines)
        }

        // To fill the upper range, minor gridlines below the next major gridline need to be calculated.
        if let last = major.last {
            let paddingLines = (1 ..< 5).map({ (majorIncrement + last * range - CGFloat($0) * minorIncrement) / range})
            minor.append(contentsOf: paddingLines)
        }
        minor = minor.filter( { $0 > 0 && $0 < 1})

        return (major, minor)
    }
}

struct GridLineMajorMinorView_Previews: PreviewProvider {
    static var previews: some View {
        GridLineMajorMinorView(xRange: (0, 100), yRange: (5, 100))
        GridLineMajorMinorView(xRange: (20, 82), yRange: (20, 82))
        GridLineMajorMinorView(xRange: (10, 37), yRange: (20, 47))
        GridLineMajorMinorView(xRange: (0.000, 0.004), yRange: (0.000, 0.002))
    }
}
