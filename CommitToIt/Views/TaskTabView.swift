//
//  TaskTabView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI

struct TaskTabView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var notificationInbox = NotificationInboxStore.shared

    @State private var showingAddMenu: Bool = false
    @State private var showingNotifications: Bool = false

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Text("My Tasks")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    Button {
                        showingNotifications = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 24).bold())
                                .foregroundColor(.accent)

                            if notificationInbox.unreadCount > 0 {
                                Text(notificationInbox.unreadCount > 9 ? "9+" : "\(notificationInbox.unreadCount)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 3)
                                    .frame(minWidth: 16, minHeight: 16)
                                    .background(Capsule().fill(Color.red))
                                    .offset(x: 10, y: -8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

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
        .sheet(isPresented: $showingNotifications) {
            NotificationInboxView()
        }
    }
}

#Preview {
    TaskTabView()
        .environmentObject(AppState(load_mock_data: true))
}
