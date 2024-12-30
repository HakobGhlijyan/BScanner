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
            VStack(alignment: .center) {
                ZStack(alignment: .trailing) {
                    TextField("Search", text: $searchText)
                        .padding(10)
                        .font(.callout)
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
                
                ScrollView {
                    if bluetoothScanner.isScanning {
                        ForEach(bluetoothScanner.discoveredPeripherals.filter {
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
                    } else {
                        DymmyView()
                    }
                }
                
                VStack {
                    HStack {
                        Button(action: {
                            self.bluetoothScanner.startScan()
                        }) {
                            Text("Start")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(buttonDisabled() ? Color.gray : Color.green)
                                .foregroundColor(Color.white)
                                .cornerRadius(15.0)
                        }
                        .disabled(buttonDisabled())
                        
                        Button(action: {
                            self.bluetoothScanner.stopScan()
                        }) {
                            Text("Stop")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(buttonDisabled() ? Color.gray : Color.red)
                                .foregroundColor(Color.white)
                                .cornerRadius(15.0)
                        }
                        .disabled(buttonDisabled())
                    }
                    NavigationLink(destination: HistoryView()) {
                        Text("Scan History")
                            .frame(height: 45)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(15.0)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .alert(
                isPresented: $bluetoothScanner.isShowingAlert,
                content: {
                    Alert(title: Text(bluetoothScanner.alertMessage), message: buttonDisabled() ? Text("Please try again , enable Bluetooth") : Text("Start Scan"))
            })
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done Search") {
                        hideKeyboard()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .hideKeyboardOnTap()
            .navigationTitle("Bluetooth Scanner")
        }
   }
    
    @discardableResult
    func buttonDisabled() -> Bool {
        switch bluetoothScanner.centralManager.state {
        case .poweredOff:
            true
        default:
            false
        }
    }
}

#Preview {
    MainView()
}
