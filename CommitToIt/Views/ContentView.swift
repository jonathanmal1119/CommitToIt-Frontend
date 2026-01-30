//
//  ContentView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/25/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState(load_mock_data: true))
}
