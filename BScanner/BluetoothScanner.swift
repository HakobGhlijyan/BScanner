//
//  BluetoothScanner.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreBluetooth

    //MARK: - MODEL
struct DiscoveredPeripheral {
        // Struct to represent a discovered peripheral
        // Структура для представления обнаруженного периферийного устройства
    var peripheral: CBPeripheral
    var advertisedData: String
}

    //MARK: - SERVICE
class BluetoothScanner: NSObject, CBCentralManagerDelegate, ObservableObject {
    //ARRAY FOR SCANED DEVICES , ITS SAVE IN DATABASE
    @Published var discoveredPeripherals = [DiscoveredPeripheral]()
    @Published var isScanning = false
    
    var centralManager: CBCentralManager!
        // Set to store unique peripherals that have been discovereds
        // Устанавливается для хранения уникальных периферийных устройств, которые были обнаружены
    var discoveredPeripheralSet = Set<CBPeripheral>()
    var timer: Timer?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
        //MARK: - START SCAN
    func startScan() {
        if centralManager.state == .poweredOn {
                // Set isScanning to true and clear the discovered peripherals list
                // Установите для параметра isScanning значение true и очистите список обнаруженных периферийных устройств
            isScanning = true
            discoveredPeripherals.removeAll()
            discoveredPeripheralSet.removeAll()
            objectWillChange.send()
            
                // Start scanning for peripherals
                // Начните поиск периферийных устройств
            centralManager.scanForPeripherals(withServices: nil)
            
                // Start a timer to stop and restart the scan every 10 seconds
                // Запустите таймер, чтобы останавливать и перезапускать сканирование каждые 10 секунды
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
                self?.centralManager.stopScan()
                self?.centralManager.scanForPeripherals(withServices: nil)
            }
        }
    }
    
        //MARK: - START SCAN
    func stopScan() {
            // Set isScanning to false and stop the timer
            // Установите isScanning в значение false и остановите таймер
        isScanning = false
        timer?.invalidate()
        centralManager.stopScan()
    }
    
        //MARK: - DEVICE STATE
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unknown")
                stopScan()
            case .resetting:
                print("central.state is .resetting")
                stopScan()
            case .unsupported:
                print("central.state is .unsupported")
                stopScan()
            case .unauthorized:
                print("central.state is .unauthorized")
                stopScan()
            case .poweredOff:
                print("central.state is .poweredOff")
                stopScan()
            case .poweredOn:
                print("central.state is .poweredOn")
                startScan()
            @unknown default:
                print("central.state is unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            // Build a string representation of the advertised data and sort it by names
            // Создайте строковое представление объявленных данных и отсортируйте их по именам
        var advertisedData = advertisementData.map { "\($0): \($1)" }.sorted(by: { $0 < $1 }).joined(separator: "\n")
        
            // Convert the timestamp into human readable format and insert it to the advertisedData String
            // Преобразуйте временную метку в удобочитаемый формат и вставьте ее в строку advertisedData
        let timestampValue = advertisementData["kCBAdvDataTimestamp"] as! Double
//        print(timestampValue)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: timestampValue))
        
        advertisedData = "actual rssi: \(RSSI) dB\n" + "Timestamp: \(dateString)\n" + advertisedData
        
            // If the peripheral is not already in the list
            // Если периферийного устройства еще нет в списке
        if !discoveredPeripheralSet.contains(peripheral) {
                // Add it to the list and the set
                // Добавьте его в список и установите
            discoveredPeripherals.append(DiscoveredPeripheral(peripheral: peripheral, advertisedData: advertisedData))
            discoveredPeripheralSet.insert(peripheral)
            objectWillChange.send()
        } else {
                // If the peripheral is already in the list, update its advertised data
                // Если периферийное устройство уже есть в списке, обновите его объявленные данные
            if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
                discoveredPeripherals[index].advertisedData = advertisedData
                objectWillChange.send()
            }
        }
    }
}
