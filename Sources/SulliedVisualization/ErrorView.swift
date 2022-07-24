import SwiftUI

struct ErrorView: View {
    var message: String
    var width: CGFloat
    var height: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .path(in: CGRect(x: 0, y: 0, width: width, height: height))
                .fill(Color.gray)
                .opacity(0.5)
            Text(message)
                .font(.headline)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            ErrorView(message: "No data", width: proxy.size.width, height: proxy.size.height)
        }
    }
}
