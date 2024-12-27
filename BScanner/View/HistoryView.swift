//
//  HistoryView.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = ScanHistoryViewModel()
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
                                Text("RSSI: \(device.advertisedData) dB")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .listStyle(.plain)
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
