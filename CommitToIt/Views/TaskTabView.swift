//
//  TaskTabView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI

struct TaskTabView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var showingAddMenu: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Text("My Tasks")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        showingAddMenu.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 30).bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 20)
                        .foregroundColor(.accent)
                    
                }
                .padding(.bottom, 1)
                
                Color.primary.opacity(0.1)
                    .frame(height: 2)
                
                TaskStatsView()
                    .padding(10)
                
                Color.primary.opacity(0.1)
                    .frame(height: 2)
                
                TaskListView(show_create_new_task: $showingAddMenu)
            }
        }
    }
}

#Preview {
    TaskTabView()
        .environmentObject(AppState(load_mock_data: true))
}
