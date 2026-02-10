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
    var showUnclaimedRewards: Bool = false
        
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
                ForEach(appState.user_rewards.filter { reward in
                    showUnclaimedRewards ? (reward.redeemed_at == nil) : true
                }) { reward in
                   RewardCard(reward: reward, showAdvancedInfo: showAdvancedInfo)
                }
                    
                    
            }
            .listStyle(.plain)
        }
    }
}

struct RewardCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let reward: UserReward
    var showAdvancedInfo: Bool
    @State private var success: Bool = false
    @State private var failed: Bool = false
    
    var body: some View {
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
                        ZStack {
                            if (success) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(invertTheme())
                                }
                                .padding(8)
                                .padding(.horizontal, 20)
                                .background(.accent)
                                .cornerRadius(10)
                            }
                            else if (failed) {
                                HStack {
                                    Image(systemName: "xmark")
                                        .foregroundColor(invertTheme())
                                }
                                .padding(8)
                                .padding(.horizontal, 20)
                                .background(.red)
                                .cornerRadius(10)
                            }
                            else {
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
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut(duration: 0.35), value: success)
                        .animation(.easeInOut(duration: 0.35), value: failed)
                    }
                }
            }
        }
    }
    
    func invertTheme() -> Color {
        colorScheme == .dark ? .white : .black
    }
    
    func redeemReward(reward: UserReward) {
        Task {
            do {
                let response = try await RewardService.redeemAvailableReward(user_reward_id: reward.id)
                
                if !response {
                    return
                }
                
                success = true
                
                AppState.shared.markRewardAsRedeemed(rewardId: reward.id)

                let syncStats = try await UserService.fetchUserStats(user_id: AppState.shared.user_id)
                
                AppState.shared.setUserStats(syncStats)
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                success = false
                
            } catch {
                failed = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                failed = false
                print("[RedeemReward] Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    RewardsListView(showAdvancedInfo: true)
        .environmentObject(AppState.shared)
}

