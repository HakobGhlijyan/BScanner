//
//  DiscoveredPeripheral.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreBluetooth
import CoreData

struct DiscoveredPeripheral {
    var peripheral: CBPeripheral
    var advertisedData: String
}
