//
//  ContentView.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreBluetooth
import CoreData

struct MainView: View {
    @ObservedObject private var bluetoothScanner = BluetoothScanner()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .trailing) {
                    TextField("Search", text: $searchText)
                        .padding()
                    
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                    
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
                .padding(.bottom)
                
                if bluetoothScanner.isScanning {
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
                } else {
                    DymmyView()
                        .padding(.bottom)
                }
                
                HStack {
                    Button(action: {
                        self.bluetoothScanner.startScan()
                    }) {
                        Text("Start")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(15.0)
                    
                    Button(action: {
                        self.bluetoothScanner.stopScan()
                    }) {
                        Text("Stop")
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(15.0)
                    
                    Spacer()
                    
                    NavigationLink(destination: HistoryView()) {
                        Text("Scanning History")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(15.0)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Bluetooth Scanner")
        }
    }
}

#Preview {
    MainView()
}
