import SwiftUI

struct TaskStatsView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text("000")
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
                    Text("000")
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
                    Text("000")
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
}


