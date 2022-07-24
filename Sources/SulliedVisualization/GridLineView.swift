import SwiftUI

struct GridLine: Identifiable {
    let id: Int
    let y: CGFloat

    init(_ y: CGFloat) {
        self.id = Int(y)
        self.y = y
    }
}

struct GridLineView: View {
    let width: CGFloat
    let height: CGFloat
    let lines: [GridLine]

    var body: some View {
        ZStack {
            ForEach(lines) { line in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: line.y))
                    path.addLine(to: CGPoint(x: self.width, y: line.y))
                }
                .stroke(style: StrokeStyle(dash: [CGFloat(5)]))
            }
        }
        .frame(width: self.width, height: self.height)
    }

    init(width: CGFloat, height: CGFloat, count: Int) {
        self.width = width
        self.height = height

        var lines = [GridLine]()
        for i in stride(from: 1, through: count, by: 1) {
            lines.append(GridLine(height - CGFloat(i) * (self.height / (0.5 + CGFloat(count)))))
        }
        self.lines = lines
    }
}

struct GridLineView_Previews: PreviewProvider {
    static var previews: some View {
        GridLineView(width: 400, height: 400, count: 6)
    }
}
