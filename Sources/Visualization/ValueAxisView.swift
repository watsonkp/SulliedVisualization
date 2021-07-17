import Foundation
import SwiftUI

struct AxisLabel: Identifiable {
    var id: Int
    var label: String
    
    init(_ value: Int) {
        self.id = value
        self.label = String(value)
    }
}

struct ValueAxis {
    let labels: [AxisLabel]

    // Count parameter is a maximum
    init(min: Int, max: Int, count: Int) {
        // Never underestimate step by adding 1
        // Reduce count by 2 to allow for first and last being outside min and max
        let step = (max - min) / (count - 2) + 1
        let niceStep = (step + 10) / 10 * 10
        let start = min / niceStep * niceStep
        let end = (max + niceStep) / niceStep * niceStep

        let values = stride(from: start, through: end, by: niceStep)
        self.labels = values.map { value in
            AxisLabel(value)
        }
    }

    func view(height: CGFloat) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(self.labels.last!.label)
                    .frame(width: 50,
                           height: 50,
                           alignment: Alignment.bottom)
                ForEach(self.labels.reversed().suffix(from: 1)) { label in
                    Text(label.label)
                        .frame(width: 50,
                           height: CGFloat(Int(height - 100) / (labels.count - 1)),
                           alignment: Alignment.bottom)
                }
            }
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: height - 50))
            }
            .stroke()
            .frame(width: 1)
        }
        .frame(height: height - 50)
    }
}

struct ValueAxisView_Previews: PreviewProvider {
    static var previews: some View {
        let axis = ValueAxis(min: 83, max: 195, count: 5)
        return axis.view(height: 500)
    }
}
