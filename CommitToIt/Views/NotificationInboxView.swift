//
//  NotificationInboxView.swift
//  CommitToIt
//

import SwiftUI

struct NotificationInboxView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var inbox = NotificationInboxStore.shared

    var body: some View {
        NavigationStack {
            Group {
                if inbox.notifications.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 30))
                        Text("No Notifications Yet")
                            .font(.title3)
                    }
                    .opacity(0.75)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(inbox.notifications) { notification in
                            notificationRow(notification)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        inbox.clear(id: notification.id)
                                    } label: {
                                        Label("Clear", systemImage: "xmark")
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    inbox.markAsRead(id: notification.id)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Mark all as read") {
                        inbox.markAllAsRead()
                    }
                    .disabled(inbox.unreadCount == 0)
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
        .presentationDragIndicator(.visible)
    }

    private func notificationRow(_ notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(notification.isRead ? Color.clear : Color.red)
                .frame(width: 8, height: 8)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 16, weight: .semibold))

                Text(notification.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Text(notification.date.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotificationInboxView()
}
