import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: AppState

    @State private var isLoading = false
    @State private var errorMessage: String?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Text("Redeem Points")
                .font(.title.bold())

            Color.primary.opacity(0.3)
                .frame(height: 2)

            ProgressBarView(value: 10, total: 100)
                .padding(10)

            Color.primary.opacity(0.3)
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
                    VStack(spacing: 16) {
                        ForEach(dataManager.rewards) { reward in
                            rewardCard(reward: reward)
                        }
                    }
                }
                .frame(maxHeight: 500)
            }

            Spacer()
        }
        .padding()
//        .onAppear {
//            fetchRewards()
//        }
        .onReceive(dataManager.$rewards) { _ in
            isLoading = false
        }
        .onReceive(dataManager.$rewardsError) { error in
            if let error = error {
                errorMessage = error
                isLoading = false
            }
        }
    }

    // MARK: - Reward Card
    func rewardCard(reward: Reward) -> some View {
        HStack {
            VStack {
                Image(systemName: reward.icon)
                    .font(.system(size: 25))
            }
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
                // TODO: Redemption functionality
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

    private func fetchRewards() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://127.0.0.1:3001/api/reward/") else {
            self.errorMessage = "Invalid rewards URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }
            
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error (\(http.statusCode))"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }
            
            do {
                let rewards = try JSONDecoder().decode([Reward].self, from: data)
                DispatchQueue.main.async {
                    self.dataManager.rewards = rewards
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse rewards"
                    self.isLoading = false
                }
            }
        }
        .resume()
    }
}

#Preview {
    let dm = DataManager()
    let ap = AppState()
    dm.rewards = [
        Reward(id: UUID(), title: "Preview Reward", description: "Preview only", cost: 50, icon: "gift.fill")
    ]
    return RewardsView()
        .environmentObject(dm)
        .environmentObject(ap)
}
