//
//  MainTabView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct MainTabView: View {
    //@State private var selectedTab: Tabs = .home
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack (alignment: .bottom) {
            Group {
                switch appState.selectedTab {
                    case .home:
                        HomePageView()
                    case .tasks:
                        TaskTabView()
                    case .rewards:
                        RewardsView()
                    case .history:
                        EmptyView()
                    case .profile:
                        HistoryView()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            HStack {
                BottomNavBar()
            }
        }
        .animation(.easeIn(duration: 0), value: appState.selectedTab)
    }
}

struct BottomNavBar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack (spacing:45) {
            navButton(icon: "house.fill", tab: .home)
            navButton(icon: "list.clipboard.fill", tab: .tasks)
            navButton(icon: "giftcard.fill", tab: .rewards)
            navButton(icon: "clock.arrow.circlepath", tab: .history)
            navButton(icon: "person.fill", tab: .profile)
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
                appState.selectedTab = tab
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(appState.selectedTab == tab ? .accent : .gray)
                .scaleEffect(appState.selectedTab == tab ? 1.3 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState(load_mock_data: true))
}
