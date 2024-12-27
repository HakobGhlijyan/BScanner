//
//  DeviceEntity.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreData

@objc(DeviceEntity)
class DeviceEntity: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var uuid: String
    @NSManaged var rssi: Int32
    @NSManaged var timestamp: Date
    @NSManaged var scanSessions: NSSet?  
    @NSManaged var advertisedData: String
    
    func addToScanSessions(_ value: ScanSession) {
        let sessions = self.mutableSetValue(forKey: "scanSessions")
        sessions.add(value)
    }

    func removeFromScanSessions(_ value: ScanSession) {
        let sessions = self.mutableSetValue(forKey: "scanSessions")
        sessions.remove(value)
    }
}

extension DeviceEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeviceEntity> {
        return NSFetchRequest<DeviceEntity>(entityName: "DeviceEntity")
    }
}
