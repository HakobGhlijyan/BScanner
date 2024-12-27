//
//  BScannerApp.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI

@main
struct BScannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
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
