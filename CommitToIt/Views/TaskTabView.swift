//
//  TaskTabView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI

struct TaskTabView: View {
    var body: some View {
        VStack {
            Text("My Tasks")
                .font(.largeTitle.bold())
            
            Color.primary.opacity(0.1)
                .frame(height: 2)
            
            TaskStatsView()
                .padding(10)
            
            Color.primary.opacity(0.1)
                .frame(height: 2)
            
            TaskListView()
        }
    }
}

#Preview {
    TaskTabView()
}
