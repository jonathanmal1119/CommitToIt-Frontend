import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var appState: AppState

    // Switch to global isLoading
    @State private var isLoading = false
    @State private var errorMessage: String?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            ZStack {
                Text("Redeem Points")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
//                Button {
//                    
//                } label: {
//                    Image(systemName: "plus")
//                        .font(.system(size: 30).bold())
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                    .padding(.trailing, 0)
//                    .foregroundColor(.accent)
                
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
                        ForEach(appState.redeemable_rewards) { reward in
                            rewardCard(reward: reward)
                        }
                    }
                }
                .frame(maxHeight: 500)
            }

            Spacer()
        }
        .padding()
    }

    // Reward Card
    func rewardCard(reward: Reward) -> some View {
        HStack {
            VStack {
                Image(systemName: reward.icon)
                    .font(.system(size: 25))
            }
            .frame(maxWidth: 30, maxHeight: 40)
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
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.leading, 5)

            Spacer()

            Button {
                //fetchAvailableRewards()
            } label: {
                HStack {
                    Text("\(reward.cost)")
                        .foregroundColor(invertTheme())
                    Image(systemName: "star.fill")
                        .foregroundColor(invertTheme())
                }
                .padding(6)
                .background(.accent.opacity(0.4))
                .cornerRadius(10)
            }
            
        }
        .padding(10)
    }

    func invertTheme() -> Color {
        colorScheme == .dark ? .white : .black
    }
}

#Preview {
    RewardsView()
        .environmentObject(AppState(load_mock_data: true))
}
