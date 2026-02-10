//
//  HistoryView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/8/26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    
    @State var tab : HistoryTabs = .rewards
    
    var body: some View {
        
        VStack (alignment: .leading) {
            Text("History")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.largeTitle.bold())
            HStack (spacing: 20) {
                Button {
                    tab = .rewards
                } label: {
                    VStack {
                        Text("Rewards")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(tab == .rewards ? 1 : 0.3))
                            .padding(.horizontal, 10)
                            .cornerRadius(10)
                            .padding(.vertical, 5)
                            .animation(.easeInOut, value: 0.6)
                            
                        
                        Color.primary
                            .opacity(tab == .rewards ? 1 : 0.3)
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .animation(.easeInOut, value: 0.6)
                    }
                }
                
                Button {
                    tab = .tasks
                } label: {
                    VStack {
                        Text("Tasks")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(tab == .tasks ? 1 : 0.3))
                            .padding(.horizontal, 10)
                            .cornerRadius(10)
                            .padding(.vertical, 5)
                            .animation(.easeInOut, value: 0.6)
                        
                        Color.primary
                            .opacity(tab == .tasks ? 1 : 0.3)
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .animation(.easeInOut, value: 0.6)
                    }
                }
            }
            .padding(.horizontal, 10)
            
            Group {
                switch tab {
                    case .rewards:
                        RewardsListView(showAdvancedInfo: true, showUnclaimedRewards: true)
                    case .tasks:
                        TaskHistoryView()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80)
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState.shared)
}
