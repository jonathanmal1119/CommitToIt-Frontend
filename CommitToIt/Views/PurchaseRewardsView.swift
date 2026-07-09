import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var appState: AppState

    // Switch to global isLoading
    @State private var isLoading = false
    @State private var errorMessage: String?

    @Environment(\.colorScheme) private var colorScheme

    var sortedRewards: [PurchaseableReward] {
        appState.redeemable_rewards.sorted { $0.cost < $1.cost }
    }

    var body: some View {
        VStack {
            ZStack {
                Text("Redeem Points")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

            }
            .padding(.bottom, 1)

            Color.primary.opacity(0.1)
                .frame(height: 2)

            ProgressBarView()

            Color.primary.opacity(0.1)
                .frame(height: 2)

            if isLoading {
                ProgressView("Loading rewards...")
                    .frame(maxHeight: 500)
            } else if let errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .frame(maxHeight: 500)
            } else {
                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(sortedRewards) { reward in
                            RewardCardView(reward: reward)
                        }
                    }
                }
                .frame(maxHeight: 500)
            }

            Spacer()
        }
        .padding()
    }
}

struct RewardCardView : View {
    let reward: PurchaseableReward
    @State private var success: Bool = false
    @State private var fail: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: reward.icon)
                    .font(.system(size: 25))
            }
            .frame(width: 30, height: 30)
            .padding(10)
            .background(.accent.opacity(0.4))
            .cornerRadius(10)

            VStack(alignment: .leading) {
                
                Text(reward.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(reward.description)
                    .font(.footnote)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .padding(.leading, 5)
            .padding(.trailing, 10)

            Spacer()

            Button {
                purchaseReward(reward: reward)
            } label: {
                ZStack {
                    if (success) {
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(invertTheme())
                        }
                        .transition(.opacity.combined(with: .scale))
                        .padding(6)
                        .padding(.horizontal, 20)
                        .background(.accent)
                        .cornerRadius(10)
                    }
                    else if (fail) {
                        HStack {
                            Image(systemName: "xmark")
                                .foregroundColor(invertTheme())
                        }
                        .transition(.opacity.combined(with: .scale))
                        .padding(6)
                        .padding(.horizontal, 20)
                        .background(.red)
                        .cornerRadius(10)
                    }
                    else {
                        HStack {
                            Text("\(reward.cost)")
                                .foregroundColor(invertTheme())
                            Image(systemName: "star.fill")
                                .foregroundColor(invertTheme())
                        }
                        .transition(.opacity.combined(with: .scale))
                        .padding(6)
                        .background(.accent.opacity(0.4))
                        .cornerRadius(10)
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: success)
                
            }
            
        }
        .padding(10)
    }
    
    func purchaseReward(reward: PurchaseableReward) {
        Task {
            do {
                let response = try await RewardService.purchaseAvailableReward(reward_id: reward.id)
                
                let syncStats = try await UserService.fetchUserStats(user_id: AppState.shared.user_id)

                AppState.shared.addUserReward(response[0])
                AppState.shared.setUserStats(syncStats)
                
                success = true
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                 
                success = false
            } catch {
                fail = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                fail = false
                print("[PurchaseReward] Error: \(error)")
            }
        }
    }
    
    func invertTheme() -> Color {
        colorScheme == .dark ? .white : .black
    }
}

#Preview {
    RewardsView()
        .environmentObject(AppState(load_mock_data: true))
}
