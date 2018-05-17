

import Foundation
import CoreLocation

struct ItemConstant {
    static let nameKey = "name"
    static let uuidKey = "uuid"
    static let majorKey = "major"
    static let minorKey = "minor"
    static let desc = "desc"
}

class Item: NSObject, NSCoding {
    let name: String
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    var beacon: CLBeacon?
    var desc: String?
    init(name: String, uuid: UUID, major: Int, minor: Int){
        self.name = name
        self.uuid = uuid
        self.majorValue = CLBeaconMajorValue(major)
        self.minorValue = CLBeaconMinorValue(minor)
        self.desc = "This is my notification bitch!🖕🏾"
    }
    convenience init(name: String, uuid: UUID, major: Int, minor: Int, description: String) {
        self.init(name: name, uuid: uuid, major: major, minor: minor)
        self.desc = description
    }
    
    // MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        let aName = aDecoder.decodeObject(forKey: ItemConstant.nameKey) as? String
        name = aName ?? ""
        
        let aUUID = aDecoder.decodeObject(forKey: ItemConstant.uuidKey) as? UUID
        uuid = aUUID ?? UUID()
        
        majorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.majorKey))
        minorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.minorKey))
        desc = aDecoder.decodeObject(forKey: ItemConstant.desc) as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: ItemConstant.nameKey)
        aCoder.encode(uuid, forKey: ItemConstant.uuidKey)
        aCoder.encode(Int(majorValue), forKey: ItemConstant.majorKey)
        aCoder.encode(Int(minorValue), forKey: ItemConstant.minorKey)
        aCoder.encode(desc, forKey: ItemConstant.desc)
    }
    
    func asBeaconRegion() -> CLBeaconRegion{
        return CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: name)
    }
    
    func locationString() -> String{
        guard let beacon = beacon else { return "Location: Unknown"}
        //let proximity = nameForProximity(beacon.proximity)
        let accuracy = String(format: "%2f", beacon.accuracy)
        
        var position = ""
        if beacon.proximity != .unknown {
            position = "\(accuracy)m"
        } else {
            position = "\(accuracy)m"
        }
        return position
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String{
        switch proximity{
        case .far:
            return "Far"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .unknown:
            return "Unknown"
        }
    }
    static func == (item: Item, beacon: CLBeacon) -> Bool{
        return ((item.uuid.uuidString == beacon.proximityUUID.uuidString) &&
            (Int(item.majorValue) == Int(truncating: beacon.major)) &&
            (Int(item.minorValue) == Int(truncating: beacon.major)))
    }
    
}
