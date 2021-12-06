import SwiftUI

// Zone 1: 50% - 60%
// Zone 2: 60% - 70%
// Zone 3: 70% - 80%
// Zone 4: 80% - 90%
// Zone 5: 90% - 100%
struct ZoneView: View {
    let zones: [CGRect]
    let colors: [Color]

    var body: some View {
        ZStack {
            ForEach(0..<zones.count) { i in
                Rectangle().path(in: zones[i]).fill(colors[i])
            }
        }
    }

    init(width viewWidth: CGFloat, height viewHeight: CGFloat, max: Int, valueRange: (Int, Int)) {
        let colorPalette = [Color.gray, Color.blue, Color.green, Color.yellow, Color.red]
        let bounds = stride(from: 0.5, to: 1.0, by: 0.1)

        var zones = [CGRect]()
        var colors = [Color]()
        for (bound, color) in zip(bounds, colorPalette) {
            var high = (bound + 0.1) * CGFloat(max)
            var low = bound * CGFloat(max)
            // Zone is above visible area
            if low > CGFloat(valueRange.1) {
                // Subsequent zones will also be above the area
                break
            }
            // Zone is partially above visible area
            if high > CGFloat(valueRange.1) && low < CGFloat(valueRange.1) {
                high = CGFloat(valueRange.1)
            }
            // Zone is below visible area
            if high < CGFloat(valueRange.0) {
                continue
            }
            // Zone is partially below visible area
            if low < CGFloat(valueRange.0) && high > CGFloat(valueRange.0) {
                low = CGFloat(valueRange.0)
            }

            let scaledHigh = (high - CGFloat(valueRange.0)) / (CGFloat(valueRange.1 - valueRange.0))
            let y = viewHeight - viewHeight * scaledHigh
            let height = (high - low) / (CGFloat(valueRange.1 - valueRange.0)) * viewHeight
            zones.append(CGRect(x: 0, y: y, width: viewWidth, height: height))
            colors.append(color)
        }

        self.zones = zones
        self.colors = colors
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        // All zones displayed in a limited range
        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 192, valueRange: (80, 200))
        }

        // All zones displayed
        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 192, valueRange: (0, 200))
        }

        // Only display higher zones
        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 192, valueRange: (150, 200))
        }

        // Only display lower zones
        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 230, valueRange: (80, 200))
        }

        // Only display lower zones. More extreme than previous case.
        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 192, valueRange: (60, 120))
        }
    }
}
