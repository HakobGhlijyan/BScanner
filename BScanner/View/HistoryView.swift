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
        ScrollView {
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
                if !viewModel.sessions.isEmpty {
                    ForEach(viewModel.sessions, id: \.timestamp) { session in
                        Section {
                            ForEach(session.devices.filter {
                                self.searchText.isEmpty || $0.name?.lowercased().contains(self.searchText.lowercased()) == true
                            }, id: \.uuid) { device in
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
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
                                    Spacer()
                                    Image(systemName: "gear")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LinearGradient(
                                            colors: [.gray.opacity(0.02), .gray.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                )
                            }
                        } header: {
                            Text("Scan Session: - \(session.timestamp, formatter: dateFormatter)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else {
                    DymmyView()
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchSessions()
        }
        .navigationTitle("Scanning History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}
