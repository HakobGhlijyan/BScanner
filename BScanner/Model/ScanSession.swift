//
//  ScanSession.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreData

@objc(ScanSession)
class ScanSession: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var devices: Set<DeviceEntity>
    
    func addToDevices(_ value: DeviceEntity) {
        self.mutableSetValue(forKey: "devices").add(value)
    }

    func removeFromDevices(_ value: DeviceEntity) {
        self.mutableSetValue(forKey: "devices").remove(value)
    }
}

extension ScanSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScanSession> {
        return NSFetchRequest<ScanSession>(entityName: "ScanSession")
    }
}

