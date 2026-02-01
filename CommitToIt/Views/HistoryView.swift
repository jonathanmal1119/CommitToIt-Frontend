//
//  HistoryView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.627, green: 0.761, blue: 0.455, opacity: 1),
                    Color(red: 0.741, green: 0.91, blue: 0.522, opacity: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState(load_mock_data: true))
}
