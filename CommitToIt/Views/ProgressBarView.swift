import SwiftUI

struct ProgressBarView: View {
    @EnvironmentObject var appState: AppState
    
    private let total: Int = 400

    var progress: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(appState.user_stats.point_balance) / Double(total), 0), 1)
    }
    
    func circleColor(for stepProgress: Double, currentProgress: Double) -> Color {
        return currentProgress >= stepProgress ? .accent : .gray
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("\(appState.user_stats.point_balance)")
                    .font(Font.largeTitle.bold())
                    .padding(.leading, 8)
                Image(systemName: "star.fill").foregroundColor(.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("Reward Points")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .padding(.bottom, 15)
            
            ZStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 10)
                        
                        UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: 20,
                            bottomLeading: 20,
                            bottomTrailing: 0,
                            topTrailing: 0
                        ), style: .continuous)
                            .fill(.accent)
                            .frame(
                                width: geometry.size.width * CGFloat(progress),
                                height: 8
                            )
                            .animation(.spring(), value: appState.user_stats.point_balance)
                        
                    }
                    
                    // Milestone 1 (25%)
                    VStack {
                        circleColor(for: 0.25, currentProgress: progress)
                            .frame(width:5 ,height: 18)
                            .animation(.spring(), value: appState.user_stats.point_balance)
                        
                        Text((Double(total) * 0.25).formatted())
                            .font(.headline)
                            .italic()
                    }
                    .position(x: geometry.size.width * 0.25 , y: geometry.size.height + 1.0)
                    
                    // Milestone 2 (50%)
                    VStack {
                        circleColor(for: 0.5, currentProgress: progress)
                            .frame(width:5 ,height: 18)
                            .animation(.spring(), value: appState.user_stats.point_balance)

                        Text((Double(total) * 0.5).formatted())
                            .font(.headline)
                            .italic()
                    }
                    .position(x: geometry.size.width * 0.5 , y: geometry.size.height + 1.0)
                    
                    
                    // Milestone 3 (75%)
                    VStack {
                        circleColor(for: 0.75, currentProgress: progress)
                            .frame(width:5 ,height: 18)
                            .animation(.spring(), value: appState.user_stats.point_balance)
                        
                        Text((Double(total) * 0.75).formatted())
                            .font(.headline)
                            .italic()
                    }
                    .position(x: geometry.size.width * 0.75 , y: geometry.size.height + 1.0)
                }
                .frame(height: 18)
                .padding(.bottom, 25)
            }
        }
        .task {
            //syncProgressBar()
        }
    }
    
    func syncProgressBar() {

        Task {
            do {
                let response = try await RewardService.fetchAvailableRewards()

                appState.setRedeemableRewards(response)
            } catch {
                print("[ProgressBar] \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    VStack {
        ProgressBarView()
            .environmentObject(AppState(load_mock_data: true))
    }
}

//Circle()
//    .fill(circleColor(for: 0.25, currentProgress: progress))
//    .stroke(circleColor(for: 0.25, currentProgress: progress), lineWidth: 2)
//    .frame(width: 20, height: 14)
