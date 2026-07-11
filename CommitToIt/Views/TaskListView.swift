//
//  TaskListView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var appState: AppState
    
    @State var tasks : [TaskItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Binding var show_create_new_task: Bool
    @State var show_task_info: Bool = false
    @State var shown_task: TaskItem? = nil
    
    @State private var new_task_name : String = ""
    @State private var new_task_point_amt : Int = 10
    @State private var new_task_desc : String = ""
    @State private var new_task_due_date : Date = Date()
    @State private var create_task_error : String? = nil
    
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
                        if appState.user_tasks.count == 0 {
                            VStack {
                                Image(systemName: "hands.sparkles")
                                    .font(.system(size: 30))
                                Text("Congrats!\n No Tasks Left")
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                            }
                            .opacity(0.75)
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
                                        shown_task = task
                                        show_task_info = true
                                    }
                            }
                            .onDelete(perform: deleteTask)
                            .contentShape(Rectangle())
                        }
                        .listStyle(.plain)
                        .sheet(item: $shown_task) { task in
                            showTaskInfoSheet(task: task)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $show_create_new_task, onDismiss: {
            create_task_error = nil
            new_task_name = ""
            new_task_desc = ""
            new_task_due_date = Date()
        }) {
            createNewTaskEntry()
        }
    }

    func createTaskEntry(task : TaskItem) -> some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                Text("\(task.title)")
                    .font(.system(size: 20))
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Text("\((task.due_date ?? Date()).formatted(.dateTime.month(.abbreviated).day().year().hour().minute()))")
                    .font(.caption2)
            }
    
            Spacer(minLength: 40)
            
            Text("+\(task.point_value)")
            Image(systemName: "star.fill")
                .foregroundColor(.accent)
                .padding(.top, -3)
        }
    }
    
    func createNewTaskEntry() -> some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading) {
                    Text("Task Name")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack{
                        TextField("", text: $new_task_name)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text("\(new_task_point_amt)")
                            .frame(maxWidth: 20)
                            .padding(.leading, 30)
//                TextField("Reward Points", value: $new_task_point_amt, format: .number)
//                    .keyboardType(.numberPad)
//                    .textFieldStyle(.roundedBorder)
//                    .frame(maxWidth: 50)

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

                    Text("Due Date")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    DatePicker("", selection: $new_task_due_date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)

                    if let error = create_task_error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack (spacing: 20) {
                        Button {
                            create_task_error = nil
                            addTask()
                        } label : {
                            Text("Confirm")
                                .padding(5)
                                .padding([.trailing, .leading], 50)
                                .background(.secondary.opacity(0.5))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }

                        Button {
                            // Close
                            self.show_create_new_task = false
                        } label : {
                            Text("Cancel")
                                .padding(5)
                                .padding([.trailing, .leading], 50)
                                .background(Color.red.opacity(0.7))
                                .cornerRadius(10)
                                .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.show_create_new_task = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
    
    
    func deleteTask(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let deletingTask = appState.user_tasks[index]
        Task {
            do {
                let result = try await TaskService.deleteTask(task_id: deletingTask.id)

                if result {
                    appState.removeTask(id: deletingTask.id)
                    
                    // Cancel the notification for this task
                    NotificationService.shared.cancelTaskReminders(taskId: deletingTask.id)
                }
            } catch {
                print("[CompleteTask] Error: \(error)")
            }
        }
        
    }
    
    func completeTask(task: TaskItem) {
        Task {
            do {
                let result = try await TaskService.markTaskCompleted(task_id: task.id)

                if !result {
                    return
                }
                
                appState.removeTask(id: task.id)
                appState.addCompletedTask(task)
                
                // Cancel the notification for this task
                NotificationService.shared.cancelTaskReminders(taskId: task.id)
                
                let syncStats = try await UserService.fetchUserStats(user_id: appState.user_id)
                
                appState.setUserStats(syncStats)
            } catch {
                print("[CompleteTask] Error: \(error)")
            }
        }
    }
    
    private func addTask() {
        Task {
            do {
                
                let result = try await TaskService.createTask(title: new_task_name, description: new_task_desc, point_value: new_task_point_amt, due_date: new_task_due_date)
                
                print(result)
                
                guard !result.isEmpty else {
                    create_task_error = "Failed to create task: No data returned"
                    return
                }

                let newTask = result[0]
                appState.addTask(newTask)
                
                // Schedule notification if task has a due date
                if let dueDate = newTask.due_date {
                    try? await NotificationService.shared.scheduleTaskReminders(
                        taskId: newTask.id,
                        taskTitle: newTask.title,
                        dueDate: dueDate
                    )
                }
                
                // Flush Values
                new_task_name = ""
                new_task_desc = ""
                new_task_due_date = Date()

                show_create_new_task = false
            } catch {
                print("[CreateTask] Error: \(error)")
                create_task_error = "Failed to create task: \(error.localizedDescription)"
            }

        }
    }
    
    
}

struct showTaskInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @State var task: TaskItem

    @State var isEditing: Bool = false

    @State private var edited_task_name : String = ""
    @State private var edited_task_desc : String = ""
    @State private var edited_task_due_date : Date = Date()

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
                            .frame(height: 400)
                            .background(.ultraThinMaterial)
                            .cornerRadius(3)

                        Text("Due Date")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)

                        Divider()

                        DatePicker("", selection: $edited_task_due_date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)

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
                            .padding(.bottom, 10)

                        Text("Due Date")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        Text("\((task.due_date ?? Date()).formatted(.dateTime.month(.abbreviated).day().year().hour().minute()))")
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
                            updateTask()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                    else {
                        Button {
                            isEditing = true
                            edited_task_name = task.title
                            edited_task_desc = task.description ?? ""
                            edited_task_due_date = task.due_date ?? Date()
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
    
    func updateTask() {
        Task {
            do {
                let result = try await TaskService.updateTaskInfo(
                    title: edited_task_name,
                    description: edited_task_desc,
                    due_date: edited_task_due_date,
                    task_id: task.id
                )

                guard let updatedTask = result else { return }

                task = updatedTask
                appState.updateTask(updatedTask)

                // Reschedule the reminders around the new title/due date
                if let dueDate = updatedTask.due_date {
                    try? await NotificationService.shared.rescheduleTaskReminders(
                        taskId: updatedTask.id,
                        taskTitle: updatedTask.title,
                        dueDate: dueDate
                    )
                } else {
                    NotificationService.shared.cancelTaskReminders(taskId: updatedTask.id)
                }
            } catch {
                print("[UpdateTask] Error: \(error)")
            }

        }
    }
}

#Preview {
    TaskListView(show_create_new_task: .constant(false))
        .environmentObject(AppState(load_mock_data: false))
}

