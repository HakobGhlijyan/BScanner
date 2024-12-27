//
//  ContentView.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreBluetooth
import CoreData

struct ContentView: View {
    @ObservedObject private var bluetoothScanner = BluetoothScanner()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                //Search
                ZStack(alignment: .trailing) {
                        // Text field for entering search text
                        // Текстовое поле для ввода текста поиска
                    TextField("Search", text: $searchText)
                        .padding()
                    
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                        // Button for clearing search text
                        // Кнопка для очистки текста поиска
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(searchText == "" ? 0 : 1)
                    .padding(.trailing, 15)
                }
                .padding()
                
                    // List of discovered peripherals filtered by search text
                    // Список обнаруженных периферийных устройств, отфильтрованный по тексту поиска
                List(bluetoothScanner.discoveredPeripherals.filter {
                    self.searchText.isEmpty ? true : $0.peripheral.name?.lowercased().contains(self.searchText.lowercased()) == true
                }, id: \.peripheral.identifier) { discoveredPeripheral in
                    VStack(alignment: .leading) {
                        Text(discoveredPeripheral.peripheral.name ?? "Unknown Device")
                        Text(discoveredPeripheral.advertisedData)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(4)
                }
                .listStyle(.plain)
                
                //Buttons
                HStack {
                    Button(action: {
                        if self.bluetoothScanner.isScanning {
                            self.bluetoothScanner.stopScan()
                        } else {
                            self.bluetoothScanner.startScan()
                        }
                    }) {
                        if bluetoothScanner.isScanning {
                            Text("Scanning: Stop")
                        } else {
                            Text("Scanning: Start")
                        }
                    }
                    .padding()
                    .background(bluetoothScanner.isScanning ? Color.red : Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(15.0)
                    
                    NavigationLink(destination: HistoryView()) {
                        Text("Scanning History")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(15.0)
                    }
                }
            }
            .padding()
            .navigationTitle("Bluetooth Scanner")
        }
    }
}


#Preview {
    ContentView()
}

//struct HistoryView1: View {
//    @StateObject private var viewModel = DeviceListViewModel()
//    
//    var body: some View {
//        List(viewModel.devices, id: \.uuid) { device in
//            VStack(alignment: .leading) {
//                Text(device.name ?? "Unknown Device")
//                    .font(.headline)
//                    .foregroundColor(.black)
//                Text("UUID: \(device.uuid)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Text("RSSI: \(device.rssi) dB")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Text("Timestamp: \(device.timestamp, formatter: dateFormatter)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//        }
//        .onAppear {
//            viewModel.fetchDevices()
//            print("HistoryView Start")
//        }
//        .navigationTitle("Scanning History")
//    }
//    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        return formatter
//    }
//}

//struct HistoryView2: View {
//    @StateObject private var viewModel = ScanHistoryViewModel()
//    @State private var searchText = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                    // Поиск по имени устройства
//                TextField("Search by device name", text: $searchText)
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(10)
//                
//                List(viewModel.sessions, id: \.timestamp) { session in
//                    Section(header: Text("\(session.timestamp, formatter: dateFormatter)")) {
//                        ForEach(session.devices.filter {
//                            self.searchText.isEmpty || $0.name?.lowercased().contains(self.searchText.lowercased()) == true
//                        }, id: \.uuid) { device in
//                            VStack(alignment: .leading) {
//                                Text(device.name ?? "Unknown Device")
//                                    .font(.headline)
//                                    .foregroundColor(.black)
//                                Text("UUID: \(device.uuid)")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                Text("RSSI: \(device.rssi) dB")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                    }
//                }
//                .onAppear {
//                    viewModel.fetchSessions()
//                }
//                .navigationTitle("Scanning History")
//            }
//        }
//    }
//    
//
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        return formatter
//    }
//}

struct HistoryView: View {
    @StateObject private var viewModel = ScanHistoryViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                    // Поиск по имени устройства
                TextField("Search by device name", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                List(viewModel.sessions, id: \.timestamp) { session in
                    Section(header: Text("\(session.timestamp, formatter: dateFormatter)")) {
                        ForEach(session.devices.filter {
                            self.searchText.isEmpty || $0.name?.lowercased().contains(self.searchText.lowercased()) == true
                        }, id: \.uuid) { device in
                            VStack(alignment: .leading) {
                                Text(device.name ?? "Unknown Device")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text("UUID: \(device.uuid)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("RSSI: \(device.rssi) dB")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchSessions()
                }
                .navigationTitle("Scanning History")
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}


//class ScanHistoryViewModel1: ObservableObject {
//    @Published var sessions: [ScanSession] = []
//    let context = PersistenceController.shared.context
//    
//    func fetchSessions() {
//        let fetchRequest: NSFetchRequest<ScanSession> = ScanSession.fetchRequest()
//        do {
//            let fetchedSessions = try context.fetch(fetchRequest)
//            DispatchQueue.main.async {
//                self.sessions = fetchedSessions
//            }
//        } catch {
//            print("Failed to fetch sessions: \(error)")
//        }
//    }
//    
//}

class ScanHistoryViewModel: ObservableObject {
    @Published var sessions: [ScanSession] = []
    let context = PersistenceController.shared.context
    
//    // Метод для добавления сессии в базу данных
//    func stopScanAndSaveSession(forDevice deviceUUID: String) {
//        // Поиск устройства по UUID
//        let fetchRequest: NSFetchRequest<DeviceEntity> = DeviceEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "uuid == %@", deviceUUID)
//        
//        do {
//            let fetchedDevices = try context.fetch(fetchRequest)
//            if let fetchedDevice = fetchedDevices.first {
//                // Создаем новую сессию сканирования
//                let newSession = ScanSession(context: context)
//                newSession.timestamp = Date()  // Устанавливаем время сессии
//                // Можно добавить другие данные, такие как RSSI, имя устройства и т.д.
//
//                // Добавляем сессию в список сканирований устройства
//                fetchedDevice.addToScanSessions(newSession)
//
//                // Сохраняем изменения в контексте
//                try context.save()
//                print("Scan session saved successfully")
//            }
//        } catch {
//            print("Failed to fetch device or save session: \(error)")
//        }
//    }
    
    // Метод для получения всех сессий из базы данных
//    func fetchSessions() {
//        let fetchRequest: NSFetchRequest<ScanSession> = ScanSession.fetchRequest()
//    
//        do {
//            let fetchedSessions = try context.fetch(fetchRequest)
//            DispatchQueue.main.async {
//                self.sessions = fetchedSessions
//            }
//        } catch {
//            print("Failed to fetch sessions: \(error)")
//        }
//    }
    
        // Метод для загрузки сессий сканирования
    func fetchSessions() {
        let fetchRequest: NSFetchRequest<ScanSession> = ScanSession.fetchRequest()
        
            // Добавляем сортировку по времени
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let fetchedSessions = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.sessions = fetchedSessions
            }
        } catch {
            print("Failed to fetch sessions: \(error)")
        }
    }
    
}

//class DeviceListViewModel1: ObservableObject {
//    @Published var devices: [DeviceEntity] = []
//    let context = PersistenceController.shared.context
//
//    func fetchDevices() {
//        let context = PersistenceController.shared.context
//        let fetchRequest = DeviceEntity.fetchRequest() as! NSFetchRequest<DeviceEntity>
//        
//        do {
//            self.devices = try context.fetch(fetchRequest)
//        } catch {
//            print("Failed to fetch devices: \(error)")
//            self.devices = []
//        }
//    }
//    
//    @discardableResult
//    func fetchDevices() -> [DeviceEntity] {
//        let fetchRequest = DeviceEntity.fetchRequest()
//        do {
//            return try context.fetch(fetchRequest)
//        } catch {
//            print("Failed to fetch devices: \(error)")
//            return []
//        }
//    }
//}

class DeviceListViewModel: ObservableObject {
    @Published var devices: [DeviceEntity] = []
    let context = PersistenceController.shared.context
    
    func fetchDevices() {
        let fetchRequest = DeviceEntity.fetchRequest()
        do {
            let fetchedDevices = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.devices = fetchedDevices
            }
            print("Start fetch devices")
        } catch {
            print("Failed to fetch devices: \(error)")
        }
    }
}
