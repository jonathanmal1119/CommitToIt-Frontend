//
//  TaskListView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var appState: AppState
    
    @State var tasks : [Task] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    
    var body: some View {
        NavigationStack{
            Group{
                if isLoading {
                    ProgressView("Fetching your tasks pookie!")
                }
                else if let error = errorMessage {
                    VStack {
                        Text("Error: \(error)")
                    }
                }
                else {
                    List {
                        ForEach(appState.user_tasks) { task in
                            createTaskEntry(task: task)
                                .swipeActions(edge: .leading) {
                                    Button(role: .destructive) {
                                        completeTask(task: task)
                                    } label: {
                                        Label ("Complete", systemImage: "checkmark")
                                    }.tint(.accent)
                                }
                        }
                        .onDelete(perform: deleteTask)
                        
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
    
    func createTaskEntry(task : Task) -> some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                Text("\(task.title)")
                    .font(.system(size: 20))
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
    
            Spacer(minLength: 40)
            
            Text("+\(task.point_value)")
            Image(systemName: "star.fill")
                .foregroundColor(.accent)
                .padding(.top, -3)
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func completeTask(task: Task) {
        
    }
}

#Preview {
    TaskListView()
        .environmentObject(AppState(load_mock_data: true))
}
