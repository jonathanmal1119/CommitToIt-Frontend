//
//  RewardsListView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/1/26.
//

import SwiftUI

struct RewardsListView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    var showAdvancedInfo: Bool = false
    var showClaimedRewards: Bool = false
        
    var body: some View {
        ZStack {
            if appState.user_rewards.isEmpty {
                VStack {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 30))
                    Text("No Rewards Purchased")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                }
                .opacity(0.75)
            }
            
            List {
                ForEach(appState.user_rewards.filter { if (showClaimedRewards) { $0.redeemed_at != nil }) { reward in
                    redeemedCard(reward: reward)
                }
            }
            .listStyle(.plain)
        }
    }
    
    func redeemedCard(reward: Reward) -> some View {
        VStack {
            HStack {
                
                VStack(alignment: .leading) {
                    
                    Text(reward.title)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(reward.description)
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    
                    
                    if let earnedAt = reward.earned_at, showAdvancedInfo{
                        Spacer()
                        
                        Text("Purchased: \(earnedAt.formatted(.dateTime.month(.abbreviated).day().year()))").font(.caption2)
                    }
                }
                .padding([.leading], 5)

                Spacer()
                ZStack {
                    if reward.redeemed_at != nil {
                       HStack {
                           Text("Claimed")
                               .foregroundColor(invertTheme())
                       }
                       .padding(6)
                       .background(.accent.opacity(0.4))
                       .cornerRadius(10)
                    }
                    else {
                        Button {
                            redeemReward(reward: reward)
                        } label: {
                            HStack {
                                Text("Redeem")
                                    .foregroundColor(invertTheme())
                            }
                            .padding(6)
                            .background(.accent.opacity(0.4))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
    
    func invertTheme() -> Color {
        colorScheme == .dark ? .white : .black
    }
    
    func redeemReward(reward: Reward) {
        Task {
            do {
                let response = try await RewardService.redeemAvailableReward(reward_id: reward.id)
                
                if response {
                    //TODO: Update timestamp and switch UI to update
                    
                }
                
                let syncStats = try await UserService.fetchUserStats(user_id: appState.user_id)
                
                appState.setUserStats(syncStats)
            } catch {
                print("[RedeemReward] Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview("RewardsListView") {
    RewardsListView(showAdvancedInfo: true)
        .environmentObject(AppState.shared)
}
