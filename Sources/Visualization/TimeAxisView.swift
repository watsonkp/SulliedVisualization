import SwiftUI

struct TimeAxis {
    let labels: [AxisLabel]

    init(min: Double, max: Double, count: Int) {
        let minutes = Int(max / 60.0)
        let step = minutes / (count - 1)
        let niceStep = (step + 5) / 5 * 5
        let end = (minutes + niceStep) / niceStep * niceStep

        let values = stride(from: 0, through: end, by: niceStep)
        self.labels = values.map { value in
            AxisLabel(value)
        }
    }

    func view(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            // X-Axis line
            Path { path in
                path.move(to: CGPoint(x: 50, y: 0))
                path.addLine(to: CGPoint(x: width, y: 0))
            }
            .stroke()
            .frame(height: 1)

            // Labels
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 50, height: 50)

                HStack(spacing: 0) {
                    ForEach(labels) { label in
                        Text(label.label)
                            .frame(width: CGFloat(Int(width - 50) / labels.count), height: 50, alignment: Alignment.leading)
                    }
                }
            }
            .frame(width: width)
        }
    }
}

struct TimeAxisView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            TimeAxis(min: 0.0, max: 60 * 32, count: 5).view(width: proxy.size.width, height: 50)
        }
    }
}
