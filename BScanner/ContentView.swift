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
                    
//                    Button(action: {
//
//                    }) {
//                        Text("Scanning History")
//                    }
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(Color.white)
//                    .cornerRadius(15.0)
                    
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

struct HistoryView: View {
    @StateObject private var viewModel = DeviceListViewModel()
    
    var body: some View {
        List(viewModel.devices, id: \.uuid) { device in
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
                Text("Timestamp: \(device.timestamp, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            viewModel.fetchDevices()
            print("HistoryView Start")
        }
        .navigationTitle("Scanning History")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

//class DeviceListViewModel: ObservableObject {
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
