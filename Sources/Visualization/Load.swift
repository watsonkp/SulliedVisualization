import Foundation

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.module.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(Record.self):\n\(error)")
    }
}

func parse(_ data: [Record]) -> ([Double], [Int]){
    // Setting up data arrays should not be a task for the graph view
    let count = data[0].bluetoothValues.count
    var x: [Double] = Array(repeating: 0.0, count: count)
    var y: [Int] = Array(repeating: 0, count: count)
    for (index, value) in data[0].bluetoothValues.enumerated() {
        x[index] = value.timeInterval
        y[index] = value.decodedValue
    }

    return (x, y)
}

func parseLocations(_ data: [Record]) -> ([Double], [Double]) {
    let x = data[0].locations.map {$0.longitude}
    let y = data[0].locations.map {$0.latitude}
    return (x, y)
}

func parseAllLocations(_ data: [Record]) -> [([Double], [Double])] {
    var locations = [([Double], [Double])]()
    for datum in data {
        locations.append((datum.locations.map {$0.longitude}, datum.locations.map {$0.latitude}))
    }
    return locations
}
