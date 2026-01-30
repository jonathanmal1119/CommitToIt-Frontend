import SwiftUI

struct TaskStatsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text("\(appState.user_stats.completed_tasks)")
                        .font(Font.largeTitle.bold())
                        
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.accent)
                }
                .frame(alignment: .leading, )
                Text("Finished Tasks")
                    .font(.footnote)
            }
            .padding(8)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text("\(appState.user_stats.completed_projects)")
                        .font(Font.largeTitle.bold())
                    Image(systemName: "folder.fill")
                        .foregroundColor(.accent)
                }
                Text("Projects Finished")
                    .font(.footnote)
            }
            .padding(8)
            
            Spacer()
            
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text("\(appState.user_stats.total_points_earned)")
                        .font(Font.largeTitle.bold())
                        
                    Image(systemName: "star.fill")
                        .foregroundColor(.accent)
                }
                Text("Points Earned")
                    .font(.footnote)
            }
            .padding(8)
        }
    }
}

#Preview {
    TaskStatsView()
        .environmentObject(AppState(load_mock_data: true))
}


