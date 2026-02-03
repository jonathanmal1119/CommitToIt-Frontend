//
//  TaskListView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var appState: AppState
    
    // TODO: Switch to global isloading
    @State var tasks : [TaskItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Binding var show_create_new_task: Bool
    @State var show_task_info: Bool = false
    @State var shown_task: TaskItem? = nil
    
    @State private var new_task_name : String = ""
    @State private var new_task_point_amt : Int = 0
    @State private var new_task_desc : String = ""
    
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
                    if show_create_new_task {
                        createNewTaskEntry()
                    }
                    
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
                                .onTapGesture {
                                    show_task_info = true
                                    shown_task = task
                                }
                        }
                        .onDelete(perform: deleteTask)
                        .contentShape(Rectangle())
                        .sheet(isPresented: $show_task_info) {
                            if let task = shown_task {
                                showTaskInfoSheet(task: task)
                            }
                        }
                        
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
    
    func createTaskEntry(task : TaskItem) -> some View {
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
    
    func createNewTaskEntry() -> some View {
        VStack {
            Text("Task Name")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack{
                TextField("", text: $new_task_name)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    
                TextField("Reward Points", value: $new_task_point_amt, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 50)
                
                Image(systemName: "star.fill")
                    .foregroundColor(.accent)
                    .padding(.top, -3)
            }
            
            .padding(.bottom, 3)
            
            Text("Task Description")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
        
            TextEditor(text: $new_task_desc)
                .cornerRadius(3)
                .padding(1)
                .lineLimit(10)
                .truncationMode(.tail)
                .frame(height: 150)
                .background(.ultraThinMaterial)
                .cornerRadius(3)
            
            HStack (spacing: 20) {
                Button {
                    // Close
                    self.show_create_new_task = false
                    
                    // TODO: Link API Service
                    
                    
                    //Flush Values
                    new_task_name = ""
                    new_task_point_amt = 0
                } label : {
                    Text("Confirm")
                        .padding(5)
                        .padding([.trailing, .leading], 50)
                        .background(.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                
                Button {
                    // Close
                    self.show_create_new_task = false
                    
                    // Flush Values
                    new_task_name = ""
                    new_task_point_amt = 0
                } label : {
                    Text("Cancel")
                        .padding(5)
                        .padding([.trailing, .leading], 50)
                        .background(.red.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
        }
        .padding(.horizontal, 16)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func completeTask(task: TaskItem) {
        
    }
    
}

struct showTaskInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var task: TaskItem
    
    @State var isEditing: Bool = true
    
    @State private var edited_task_name : String = ""
    @State private var edited_task_desc : String = ""

    var body: some View {
        NavigationStack {
            VStack (alignment: .leading, ){
                if isEditing {
                    VStack (alignment: .leading) {
                        Text("Task Name")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()

                        TextField("", text: $edited_task_name)
                            .textFieldStyle(.roundedBorder)
                            .background(.ultraThinMaterial)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.title)
                            .padding(.top, -3)
                            .padding(.bottom, 5)
                        
                        Text("Task Description")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()

                        
                        TextEditor(text: $edited_task_desc)
                            .font(.title2)
                            .cornerRadius(3)
                            .padding(1)
                            .frame(height: 500)
                            .background(.ultraThinMaterial)
                            .cornerRadius(3)
                    }
                    .padding(10)
                } else {
                    VStack (alignment: .leading) {
                        Text("Task Name")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        Text("\(task.title)")
                            .font(.title)
                            .padding(.bottom, 10)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text("Task Description")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        Text("\(task.description ?? "")")
                            .font(.title2)
                            .padding(.top, 9)
                    }
                    .padding(10)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button {
                            isEditing = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                    else {
                        Button {
                            isEditing = true
                            edited_task_name = task.title
                            edited_task_desc = task.description ?? ""
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                   
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

            }
        }
    }
}

#Preview {
    TaskListView(show_create_new_task: .constant(false))
        .environmentObject(AppState(load_mock_data: true))
    //showTaskInfoSheet(task: .init(id: 0, title: "mock Task", description: "This is a mock task and i need to test the text editor", point_value: 10, icon: "mug.fill"))
}
