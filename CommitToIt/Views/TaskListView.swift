//
//  TaskListView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct TaskListView: View {
    @State var tasks : [Task] = [
        Task(id: UUID(), title: "Previe36d3673h3d73d7d3737337373w", point_value: 100, icon: "mug.fill"),
        Task(id: UUID(), title: "Preview", point_value: 100, icon: "mug.fill"),
        Task(id: UUID(), title: "Preview", point_value: 100, icon: "mug.fill"),
        Task(id: UUID(), title: "Preview", point_value: 100, icon: "mug.fill"),
        Task(id: UUID(), title: "Preview", point_value: 100, icon: "mug.fill")
    ]
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
                        ForEach(tasks) { task in
                            createTaskEntry(task: task)
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
            Image(systemName: task.icon)
                .foregroundColor(.accent)
                .font(.system(size: 25))
            
            Text("\(task.title)")
                .font(.system(size: 25))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer(minLength: 40)
            
            Text("+\(task.point_value)")
            Image(systemName: "star.fill")
                .foregroundColor(.accent)
                .padding(.top, -3)
            Button(){
                
            } label: {
                ZStack {
                    Circle()
                        .foregroundColor(.gray.opacity(0.2))
                        .frame(width: 30, height: 30)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15))
                    
                }
            }
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    TaskListView()
}
