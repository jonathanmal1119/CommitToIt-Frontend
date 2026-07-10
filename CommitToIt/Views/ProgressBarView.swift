import SwiftUI

struct ProgressBarView: View {
    @EnvironmentObject var appState: AppState

    @State private var displayedTier: Int?
    @State private var suppressFillAnimation: Bool = false

    private let tierSize: Int = 400

    private var pointBalance: Int {
        appState.user_stats.point_balance
    }

    /// The tier the live point balance falls into, independent of what's currently displayed.
    private var tier: Int {
        max(pointBalance, 0) / tierSize
    }

    private var effectiveTier: Int {
        displayedTier ?? tier
    }

    private var milestoneValues: [Int] {
        let floor = effectiveTier * tierSize
        return [floor + 100, floor + 200, floor + 300]
    }

    var progress: Double {
        let floor = effectiveTier * tierSize
        return min(max(Double(pointBalance - floor) / Double(tierSize), 0), 1)
    }

    func circleColor(for stepProgress: Double, currentProgress: Double) -> Color {
        return currentProgress >= stepProgress ? .accent : .gray
    }

    private var stepAnimation: Animation? {
        suppressFillAnimation ? nil : .spring()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text("\(pointBalance)")
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
                            .animation(stepAnimation, value: pointBalance)

                    }

                    // Milestone 1 (25%)
                    VStack {
                        circleColor(for: 0.25, currentProgress: progress)
                            .frame(width:5 ,height: 18)
                            .animation(stepAnimation, value: pointBalance)

                        Text(milestoneValues[0].formatted())
                            .font(.headline)
                            .italic()
                            .contentTransition(.numericText())
                    }
                    .position(x: geometry.size.width * 0.25 , y: geometry.size.height + 1.0)

                    // Milestone 2 (50%)
                    VStack {
                        circleColor(for: 0.5, currentProgress: progress)
                            .frame(width:5 ,height: 18)
                            .animation(stepAnimation, value: pointBalance)

                        Text(milestoneValues[1].formatted())
                            .font(.headline)
                            .italic()
                            .contentTransition(.numericText())
                    }
                    .position(x: geometry.size.width * 0.5 , y: geometry.size.height + 1.0)


                    // Milestone 3 (75%)
                    VStack {
                        circleColor(for: 0.75, currentProgress: progress)
                            .frame(width:5 ,height: 18)
                            .animation(stepAnimation, value: pointBalance)

                        Text(milestoneValues[2].formatted())
                            .font(.headline)
                            .italic()
                            .contentTransition(.numericText())
                    }
                    .position(x: geometry.size.width * 0.75 , y: geometry.size.height + 1.0)
                }
                .frame(height: 18)
                .padding(.bottom, 25)
            }
        }
        .onAppear {
            if displayedTier == nil {
                displayedTier = tier
            }
        }
        .onChange(of: pointBalance) { _, _ in
            let newTier = tier
            let currentTier = displayedTier ?? newTier
            guard newTier != currentTier else { return }

            suppressFillAnimation = true
            if newTier > currentTier {
                withAnimation {
                    displayedTier = newTier
                }
            } else {
                displayedTier = newTier
            }
            DispatchQueue.main.async {
                suppressFillAnimation = false
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
