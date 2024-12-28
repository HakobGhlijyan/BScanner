//
//  BluetoothScanner.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreBluetooth
import CoreData

class BluetoothScanner: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var discoveredPeripherals: [DiscoveredPeripheral] = []
    @Published var isScanning = false
    let context = PersistenceController.shared.context
    var centralManager: CBCentralManager!
    var discoveredPeripheralSet = Set<CBPeripheral>()
    var timer: Timer?
    
    @Published var isShowingAlert: Bool = false
    @Published var alertMessage: String = ""
    
    func showErrorAlert(message: String) {
        self.alertMessage = message
        self.isShowingAlert = true
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        print("Start scan")
        isScanning = true
        discoveredPeripherals.removeAll()
        discoveredPeripheralSet.removeAll()
        objectWillChange.send()
        
        centralManager.scanForPeripherals(withServices: nil)

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
            self?.centralManager.stopScan()
            self?.centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func stopScan() {
        isScanning = false
        timer?.invalidate()
        centralManager.stopScan()
        stopScanAndSaveSession()
        discoveredPeripherals.removeAll()
        print("Stop scan")
    }
    
    func stopScanAndSaveSession() {
        let newSession = ScanSession(context: context)
        newSession.timestamp = Date()
        
        for peripheral in discoveredPeripherals {
            let deviceEntity = DeviceEntity(context: context)
            deviceEntity.name = peripheral.peripheral.name
            deviceEntity.uuid = peripheral.peripheral.identifier.uuidString
            deviceEntity.rssi = Int32(peripheral.advertisedData.components(separatedBy: "actual rssi: ").last ?? "0") ?? 0
            deviceEntity.advertisedData = peripheral.advertisedData
            deviceEntity.timestamp = newSession.timestamp
            newSession.addToDevices(deviceEntity)
            
            print("Device saved successfully: \(peripheral.peripheral.name ?? "Unknown Device")")
        }

        do {
            try context.save()
            
            print("Scan session saved successfully")
        } catch {
            print("Failed to save session: \(error)")
        }
        
        print("All discovered devices have been saved to the database for session: \(newSession.timestamp)")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
            showErrorAlert(message: "Bluetooh Powered Off")
        case .poweredOn:
            print("central.state is .poweredOn")
            showErrorAlert(message: "Bluetooh Powered On")
        @unknown default:
            print("central.state is unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var advertisedData = advertisementData.map { "\($0): \($1)" }.sorted(by: { $0 < $1 }).joined(separator: "\n")
        let timestampValue = advertisementData["kCBAdvDataTimestamp"] as! Double

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: timestampValue))
        
        advertisedData = "actual rssi: \(RSSI) dB\n" + "Timestamp: \(dateString)\n" + advertisedData
        
        if !discoveredPeripheralSet.contains(peripheral) {
            discoveredPeripherals.append(DiscoveredPeripheral(peripheral: peripheral, advertisedData: advertisedData))
            discoveredPeripheralSet.insert(peripheral)
            objectWillChange.send()
        } else {
            if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
                discoveredPeripherals[index].advertisedData = advertisedData
                objectWillChange.send()
            }
        }
    }
}
