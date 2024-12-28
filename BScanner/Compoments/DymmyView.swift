//
//  DymmyView.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI

struct DymmyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "doc.text.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                
            VStack {
                Text("Start Scanning")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Device list is empty")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ForEach(0...2, id: \.self) { _ in
                    VStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .frame(maxWidth: .infinity)
                            .frame(height: 6)
                            .padding(.horizontal, 50)
                            .foregroundColor(.gray.opacity(0.2))
                        ForEach(0...2, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 4)
                                    .padding(.horizontal, 50)
                                    .padding(.trailing, 60)
                                    .foregroundColor(.gray.opacity(0.1))
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 40)
    }
}

#Preview {
    DymmyView()
}
