import SwiftUI

// Zone 1: 50% - 60%
// Zone 2: 60% - 70%
// Zone 3: 70% - 80%
// Zone 4: 80% - 90%
// Zone 5: 90% - 100%
struct ZoneView: View {
    let zones: [CGRect]
    let colors = [Color.red, Color.yellow, Color.green, Color.blue, Color.gray]

    var body: some View {
        ZStack {
            ForEach(0..<zones.count) { i in
                Rectangle().path(in: zones[i]).fill(colors[i])
            }
        }
    }

    init(width: CGFloat, height: CGFloat, max: Int, valueRange: (Int, Int)) {
        var zones = [CGRect]()
        // Height required to display the full value range
        let fullHeight = height * CGFloat(valueRange.1) / CGFloat(valueRange.1 - valueRange.0)
        // Height required to display the 100% value
        let maxHeight = fullHeight * CGFloat(max) / CGFloat(valueRange.1)
        for i in stride(from: 1.0, through: 0.6, by: -0.1) {
            var top = fullHeight - maxHeight * CGFloat(i)
            let bottom = top + 0.1 * maxHeight
            // Don't allow the top to extend above the view
            if top < 0 {
                top = 0
            }
            // Don't create zones that are above the displayed range
            if bottom < 0 {
                continue
            }
            // Don't create zones that are below the displayed range
            if top > height {
                break
            }
            zones.append(CGRect(x: 0, y: top, width: width, height: 0.1 * maxHeight))
        }
        self.zones = zones
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 192, valueRange: (80, 200))
        }

        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 192, valueRange: (0, 200))
        }

        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 192, valueRange: (150, 200))
        }

        GeometryReader { proxy in
            ZoneView(width: proxy.size.width, height: proxy.size.height, max: 230, valueRange: (80, 200))
        }
    }
}
