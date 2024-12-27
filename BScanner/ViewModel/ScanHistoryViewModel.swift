//
//  ScanHistoryViewModel.swift
//  BScanner
//
//  Created by Hakob Ghlijyan on 12/27/24.
//

import SwiftUI
import CoreData

class ScanHistoryViewModel: ObservableObject {
    @Published var sessions: [ScanSession] = []
    let context = PersistenceController.shared.context

    func fetchSessions() {
        let fetchRequest: NSFetchRequest<ScanSession> = ScanSession.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let fetchedSessions = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.sessions = fetchedSessions
            }
        } catch {
            print("Failed to fetch sessions: \(error)")
        }
    }
    
}
