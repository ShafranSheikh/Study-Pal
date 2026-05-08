import SwiftUI

struct NotificationView: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.05).ignoresSafeArea()
                
                if notificationManager.notifications.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No Notifications")
                            .font(.title3)
                            .bold()
                        Text("You're all caught up! New notifications will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(notificationManager.notifications) { notification in
                            NotificationRow(notification: notification)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteNotification)
                    }
                    .listStyle(.plain)
                    .refreshable {
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !notificationManager.notifications.isEmpty {
                        Menu {
                            Button(role: .destructive) {
                                notificationManager.clearAll()
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                            
                            Button {
                                notificationManager.markAllAsRead()
                            } label: {
                                Label("Mark all as read", systemImage: "checkmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .onAppear {
            // notificationManager.markAllAsRead() 
        }
    }
    
    private func deleteNotification(at offsets: IndexSet) {
        notificationManager.removeNotifications(at: offsets)
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(notification.isRead ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
                    .frame(width: 45, height: 45)
                
                Image(systemName: notification.title.contains("Task") ? "doc.text.fill" : "bell.fill")
                    .foregroundColor(notification.isRead ? .gray : .blue)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(notification.isRead ? .secondary : .primary)
                    
                    Spacer()
                    
                    Text(timeAgo(notification.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundColor(notification.isRead ? .secondary.opacity(0.8) : .secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.vertical, 5)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
