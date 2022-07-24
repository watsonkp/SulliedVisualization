import SwiftUI

struct TimeAxis {
    let labels: [AxisLabel]
    let minimum: Int = 0
    let maximum: Double

    init(min: Double, max: Double, count: Int) {
        let minutes = Int(max / 60.0)
        let step = minutes / (count - 1)
        let niceStep = (step + 5) / 5 * 5
        let end = (minutes + niceStep) / niceStep * niceStep

        let values = stride(from: 0, through: end, by: niceStep)
        self.labels = values.map { value in
            AxisLabel(value)
        }

        self.maximum = Double(end + niceStep / 4)
    }

    func view(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            // X-Axis line
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width, y: 0))
            }
            .stroke()
            .frame(height: 1)

            // Labels
            HStack(spacing: 0) {
                let labelWidth = Double(width) / (Double(labels.count) - 0.75)
                ForEach(labels[0..<labels.count-1]) { label in
                    Text(label.label)
                        .frame(width: CGFloat(labelWidth), height: height, alignment: Alignment.leading)
                }
                Text(labels.last!.label)
                    .frame(width: CGFloat(labelWidth / 4.0), height: height, alignment: Alignment.leading)
            }
            .frame(width: width)
        }
    }
}

struct TimeAxisView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            HStack {
                Spacer().frame(width: 50, height: 50)
                TimeAxis(min: 0.0, max: 60 * 32, count: 5).view(width: proxy.size.width - 50, height: 50)
            }
        }
    }
}
