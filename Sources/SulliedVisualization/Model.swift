import Foundation
import CoreBluetooth

struct BluetoothValue: Codable, Identifiable {
    var id: Int {
        get {
            Int(self.timeInterval * 1000)
        }
    }

    var value: String
    var timeInterval: Double
    var peripheralID: String
    var characteristicID: String
    var serviceID: String

    var decodedValue: Int {
        get {
            let id = CBUUID(string: self.characteristicID)
            let data = Data(base64Encoded: self.value)
            switch id {
            case CBUUID(string: "0x2A37"):
                return BluetoothValue.decodeHeartRate(data!)
            default:
                return 0
            }
        }
    }

    // Decode a binary value representing a heart rate to an Integer
    static func decodeHeartRate(_ data: Data) -> Int {
        // https://www.bluetooth.com/wp-content/uploads/Sitecore-Media-Library/Gatt/Xml/Characteristics/org.bluetooth.characteristic.heart_rate_measurement.xml
        var value = [UInt8](repeating:0, count: 0xf)
        value.withUnsafeMutableBytes({(bs: UnsafeMutableRawBufferPointer) -> Void in
            data.copyBytes(to: bs, count: data.count)
        })

        var heartRate: Int = -1
        switch value[0] & 0x11 {
        case 0x0:
            heartRate = Int(value[1])
        case 0x1:
            heartRate = Int(UInt16((value[1]<<8) | value[2]))
        case 0x10:
            heartRate = Int(value[1])
        case 0x11:
            heartRate = Int(UInt16((value[1]<<8) | value[2]))
        default:
            NSLog("ERROR: Unexpected heart rate format")
        }
        return heartRate
    }
}

struct LocationValue: Codable {
    var timeInterval: Double
    var longitude: Double
    var latitude: Double
    var altitude: Double
    var verticalAccuracy: Int
    var horizontalAccuracy: Int
    var speedAccuracy: Double
    var courseAccuracy: Double
}

//struct Record: Hashable, Codable {
struct Record: Codable {
    var start: Double
    var end: Double
    var bluetoothValues: [BluetoothValue]
    var locations: [LocationValue]
}
