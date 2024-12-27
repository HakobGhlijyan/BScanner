//
//  ContentView.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI

import SwiftUI
import CoreBluetooth

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
                    
                    Button(action: {
                        
                    }) {
                        Text("Scanning History")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(15.0)
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
