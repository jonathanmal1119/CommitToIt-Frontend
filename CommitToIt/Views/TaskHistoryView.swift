//
//  TaskHistoryView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/8/26.
//

import SwiftUI

struct TaskHistoryView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    
    var body: some View {
        NavigationStack{
            Group{
                if isLoading {
                    ProgressView("Fetching your tasks!")
                }
                else if let error = errorMessage {
                    VStack {
                        Text("Error: \(error)")
                    }
                }
                else {

                    ZStack{
                        if appState.user_completed_tasks.count == 0 {
                            VStack {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 30))
                                Text("No Tasks Completed")
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                            }
                            .opacity(0.75)
                        }
                        
                        List {
                            ForEach(appState.user_completed_tasks) { task in
                                createTaskEntry(task: task)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
        }
    }
    
    func createTaskEntry(task : TaskItem) -> some View {
        HStack {
            VStack (alignment: .leading) {
                Text("\(task.title)")
                    .font(.system(size: 20))
                    .lineLimit(2)
                    .truncationMode(.tail)
                 
                if let completed_at = task.completed_at {
                    Text("Completed: \(completed_at.formatted(.dateTime.month(.abbreviated).day().year()))").font(.caption2)
                }
            }
            
            Spacer(minLength: 40)
            
            Text("+\(task.point_value)")
            Image(systemName: "star.fill")
                .foregroundColor(.accent)
                .padding(.top, -3)
        }
    }
}

#Preview {
    TaskHistoryView()
        .environmentObject(AppState(load_mock_data: true))
}

