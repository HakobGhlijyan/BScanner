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


//Thread 1: "NSManagedObjects of entity 'ScanSession' do not support -mutableSetValueForKey: for the property 'devices'"
