import Foundation

// TODO: The "accelerate" library with vector operations

class Location {
    // Project a single latitude and longitude point using the Mercator projection
    // https://mathworld.wolfram.com/MercatorProjection.html
    static func project(latitude: Double, longitude: Double) -> (Double, Double) {
        let xs = toRadians(longitude)
        let ys = log(tan(Double.pi / 4 + toRadians(latitude) / 2))
        return (xs, ys)
    }

    // Project an array of latitude and longitude points using the Mercator projection
    // https://mathworld.wolfram.com/MercatorProjection.html
    static func project(latitude: [Double], longitude: [Double]) -> ([Double], [Double]) {
        let xs = longitude.map { toRadians($0) }
        let ys = latitude.map { log(tan(Double.pi / 4 + toRadians($0) / 2)) }
        return (xs, ys)
    }

    // Convert a value from degrees to radians
    static func toRadians(_ degrees: Double) -> Double {
        return Double.pi / 180 * degrees
    }
}
