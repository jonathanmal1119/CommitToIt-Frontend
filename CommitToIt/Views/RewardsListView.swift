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
        
    var body: some View {
        List {
            ForEach(appState.user_rewards) { reward in
                redeemedCard(reward: reward)
            }
        }
        .listStyle(.plain)
    }
    
    func redeemedCard(reward: Reward) -> some View {
        VStack {
            HStack {
//                VStack {
//                    Image(systemName: reward.icon)
//                        .font(.system(size: 25))
//                        .padding([.trailing, .leading], 10)
//                }
//                .frame(maxHeight: .infinity)
//                .background(.accent.opacity(0.4))
//                .cornerRadius(10)
                
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
                        
                        Text("Earned: \(earnedAt.formatted(.dateTime.month(.abbreviated).day().year()))").font(.caption2)
                    }
                }
                .padding([.leading], 5)

                Spacer()

                Button {
                    // TODO: Send Notif to me
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
    
    func invertTheme() -> Color {
        colorScheme == .dark ? .white : .black
    }
}

#Preview {
    RewardsListView(showAdvancedInfo: true)
        .environmentObject(AppState(load_mock_data: true))
}
