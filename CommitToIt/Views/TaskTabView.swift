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
                        showingAddMenu = true
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
            
//            if showingAddMenu {
//                addOverlay(showBool: $showingAddMenu)
//            }
        }
    }
}

struct addOverlay: View {
    @EnvironmentObject var appState: AppState
    
    @Binding var showBool: Bool
    
    @State private var taskName: String = ""
    @State private var reward_amount: Int = 0

    @State private var showCreateProjectScreen : Bool = false
    
    var body:  some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    Button {
                        showBool = false
                        taskName = ""
                        reward_amount = 0
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 25).bold())
                            .foregroundColor(.red)

                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(EdgeInsets(.init(top: 20, leading: 0, bottom: 0, trailing: 20)))
                        .foregroundColor(.accent)
                    
                }
                
                VStack {
                    Text("Task Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)
                    
                    TextField("", text: $taskName)
                        .foregroundColor(.primary)
                    
                    HStack () {
                        Text("Earnable Points")
                            .font(.caption)

                        Image(systemName: "star.fill")
                            .foregroundColor(.accent)
                            .padding(.top, -2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Reward Points", value: $reward_amount, format: .number)
                        .keyboardType(.numberPad)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack{
                        Button{
                            // TODO: Call create task API
                        } label: {
                            Text("Create")
                                .padding(10)
                                .background(.primary.opacity(0.2))
                                .cornerRadius(20)
                        }
                        
                    }
                    
                }
                .textFieldStyle(.roundedBorder)
                .padding(EdgeInsets(
                    .init(
                        top: 0,
                        leading: 20,
                        bottom: 20,
                        trailing: 20
                    )))
                
                
                
            }
            .background(.background.secondary)
            .cornerRadius(20)
            .padding(40)
            

        }
    }
}

#Preview {
    TaskTabView()
        .environmentObject(AppState(load_mock_data: true))
}
