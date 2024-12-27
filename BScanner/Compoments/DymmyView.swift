//
//  DymmyView.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI

struct DymmyView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
            
            VStack(alignment: .center, spacing: 40.0) {
                if #available(iOS 16.0, *) {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "doc.text.fill") // или другая иконка для старых версий iOS
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                }
                    
                VStack {
                    Text("Start Scanning")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Device list is empty")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Press start scanning button")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("And press stop save all devices ")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
            }
            .padding()
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
        .cornerRadius(10)
    }
}

#Preview {
    DymmyView()
}
