//
//  MainTabView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct MainTabView: View {
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
                    case .login:
                        LoginView()
                    case .history:
                        HistoryView()
                    case .settings:
                        SettingsView()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            HStack {
                if appState.selectedTab != .login {
                    BottomNavBar()
                }
                
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeIn(duration: 0), value: appState.selectedTab)
    }
}

struct BottomNavBar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack (spacing:40) {
            navButton(icon: "house.fill", tab: .home)
            navButton(icon: "list.clipboard.fill", tab: .tasks)
            navButton(icon: "gift.fill", tab: .rewards)
            navButton(icon: "clock.arrow.trianglehead.clockwise.rotate.90.path.dotted", tab: .history)
            navButton(icon: "gearshape.fill", tab: .settings)
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
