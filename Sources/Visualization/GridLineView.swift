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
        .frame(width: self.width, height: self.height + 50)
    }

    init(width: CGFloat, height: CGFloat, count: Int) {
        self.width = width
        self.height = height - 50

        var lines = [GridLine]()
        for i in stride(from: 0, to: count, by: 1) {
            lines.append(GridLine(50 + CGFloat(i) * (self.height / CGFloat(count))))
        }
        self.lines = lines
    }
}

struct GridLineView_Previews: PreviewProvider {
    static var previews: some View {
        GridLineView(width: 400, height: 400, count: 3)
    }
}
