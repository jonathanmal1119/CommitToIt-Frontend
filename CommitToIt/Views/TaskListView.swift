//
//  TaskListView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct TaskListView: View {
    @State private var tasks : [Task] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    //Add API call service here
    
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
                    List($tasks) { $task in
                        HStack {
                            Image(systemName: task.icon)
                            
                            Text("\(task.title)")
                            
                            Spacer()
                            
                            Text("+\(task.point_value)")
                                .foregroundColor(.gray)
                            Image(systemName: "star.fill").foregroundColor(.mint)
                            Button(){
                                
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.gray.opacity(0.2))
                                        .frame(width: 25, height: 20)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 10, weight: .bold))
                                        
                                }
                                
                                    
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadData()
                    }
                }
            }
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            tasks = [Task(id: UUID(), title: "Test Task", point_value: 10, icon: "house"),
                     Task(id: UUID(), title: "Test Task", point_value: 10, icon: "house"),
                     Task(id: UUID(), title: "Test Taskr", point_value: 10, icon: "house"),
                     Task(id: UUID(), title: "Test Taske", point_value: 10, icon: "house"),]
            isLoading = false
        }
//        catch {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
    }
}

#Preview {
    
    TaskListView().cornerRadius(20).background(.black)
}
