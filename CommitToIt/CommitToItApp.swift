//
//  CommitToItApp.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/25/26.
//

import SwiftUI

@main
struct CommitToItApp: App {
    @StateObject var appState = AppState()
    @StateObject var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(dataManager)
        }
    }
}
