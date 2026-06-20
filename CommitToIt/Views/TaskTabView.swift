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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showingAddMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 30).bold())
                            .rotationEffect(.degrees(showingAddMenu ? 45 : 0))
                            .foregroundColor(showingAddMenu ? .red : .accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)

                    
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
