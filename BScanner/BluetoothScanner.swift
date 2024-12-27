//
//  BluetoothScanner.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreBluetooth
import CoreData

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
    
    let context = PersistenceController.shared.context
    
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
//    func stopScan() {
//            // Set isScanning to false and stop the timer
//            // Установите isScanning в значение false и остановите таймер
//        isScanning = false
//        timer?.invalidate()
//        centralManager.stopScan()
//    }
    
    func stopScan() {
            // Set isScanning to false and stop the timer
            // Установите isScanning в значение false и остановите таймер
        isScanning = false
        timer?.invalidate()
        centralManager.stopScan()

        for discoveredPeripheral in discoveredPeripherals {
            saveDeviceToDatabase(
                name: discoveredPeripheral.peripheral.name,
                uuid: discoveredPeripheral.peripheral.identifier.uuidString,
                rssi: Int32(discoveredPeripheral.advertisedData.components(separatedBy: "rssi: ").last ?? "0") ?? 0,
                timestamp: Date()
            )
        }

        print("All discovered devices have been saved to the database.")
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
   
//    func saveDeviceToDatabase(name: String?, uuid: String, rssi: Int, timestamp: Date) {
//        let device = DeviceEntity(context: context)
//        device.name = name
//        device.uuid = uuid
//        device.rssi = Int32(rssi)
//        device.timestamp = timestamp
//
//        do {
//            try context.save()
//        } catch {
//            print("Error saving device: \(error)")
//        }
//    }
    
    func saveDeviceToDatabase(name: String?, uuid: String, rssi: Int32, timestamp: Date) {
        let context = PersistenceController.shared.context

        let fetchRequest = DeviceEntity.fetchRequest() 
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)

        do {
            let existingDevices = try context.fetch(fetchRequest)

            if let existingDevice = existingDevices.first {
                // Обновить существующее устройство
                existingDevice.name = name
                existingDevice.rssi = rssi
                existingDevice.timestamp = timestamp
            } else {
                // Создать новое устройство
                let newDevice = DeviceEntity(context: context)
                newDevice.name = name
                newDevice.uuid = uuid
                newDevice.rssi = rssi
                newDevice.timestamp = timestamp
            }

            try context.save()
            print("Device saved successfully: \(name ?? "Unknown Device")")
        } catch {
            print("Failed to save device: \(error)")
        }
    }

    func showErrorAlert(message: String) {
        // Логика для отображения ошибки через Alert
    }
    
}

//MARK: - MODEL + PersistenceController

@objc(DeviceEntity)
class DeviceEntity: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var uuid: String
    @NSManaged var rssi: Int32
    @NSManaged var timestamp: Date
}

class PersistenceController {
    static let shared = PersistenceController()

    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "BScannerDB") // Замените "ModelName" на имя вашей модели .xcdatamodeld
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
//    func fetchDevices() -> [DeviceEntity] {
//        let fetchRequest = DeviceEntity.fetchRequest() as! NSFetchRequest<DeviceEntity>
//        do {
//            return try context.fetch(fetchRequest)
//        } catch {
//            print("Failed to fetch devices: \(error)")
//            return []
//        }
//    }
    
    func fetchDevices() -> [DeviceEntity] {
        let fetchRequest = DeviceEntity.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch devices: \(error)")
            return []
        }
    }
}

extension DeviceEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeviceEntity> {
        return NSFetchRequest<DeviceEntity>(entityName: "DeviceEntity")
    }
}

/*
 // cmd + opt + / ->
 
 /// Description
 /// - Parameters:
 ///   - name: name description
 ///   - uuid: uuid description
 ///   - rssi: rssi description
 ///   - timestamp: timestamp description
 
 */

