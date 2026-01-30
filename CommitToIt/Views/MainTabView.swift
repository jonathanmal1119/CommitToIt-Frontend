//
//  MainTabView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

enum Tabs {
    case home
    case tasks
    case rewards
    case history
    case transition
}


struct MainTabView: View {
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        ZStack (alignment: .bottom) {
            Group {
                switch selectedTab {
                    case .home:
                        HomePageView()
                    case .tasks:
                        TaskTabView()
                    case .rewards:
                        RewardsView()
                    case .history:
                        EmptyView()
                    case .transition:
                        HistoryView()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            HStack {
                BottomNavBar(selectedTab: $selectedTab)
            }
        }
        .animation(.easeIn(duration: 0), value: selectedTab)
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tabs
    
    var body: some View {
        HStack (spacing:50) {
            navButton(icon: "house.fill", tab: .home)
            navButton(icon: "list.clipboard.fill", tab: .tasks)
            navButton(icon: "giftcard.fill", tab: .rewards)
            navButton(icon: "clock.arrow.circlepath", tab: .transition)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThickMaterial)
                .shadow(radius: 10)
        )
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    private func navButton(icon: String, tab: Tabs) -> some View {
        Button {
            withAnimation(.spring(dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(selectedTab == tab ? .accent : .gray)
                .scaleEffect(selectedTab == tab ? 1.3 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState(load_mock_data: true))
}
