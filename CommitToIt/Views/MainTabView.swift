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
}


struct MainTabView: View {
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
//        TabView(selection: $selectedTab) {
//            HomePageView()
//                .tabItem {
//                    Image(systemName: "house.fill")
//                    Text("Home")
//                }
//                .tag(0)
//            
//            TaskListView()
//                .tabItem {
//                    Image(systemName: "list.bullet")
//                    Text("List")
//                }
//                .tag(1)
//        }
        
        ZStack (alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomePageView()
                case .tasks:
                    TaskListView()
                case .rewards:
                    EmptyView()
                case .history:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            HStack {
                BottomNavBar(selectedTab: $selectedTab)
            }
            //.background(.red)
            
            
        }
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tabs
    
    var body: some View {
        HStack (spacing:30) {
            navButton(icon: "house.fill", tab: .home)
            navButton(icon: "list.clipboard.fill", tab: .tasks)
            navButton(icon: "giftcard.fill", tab: .rewards)
            navButton(icon: "clock.arrow.circlepath", tab: .history)
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
                .foregroundColor(selectedTab == tab ? .mint : .gray)
                .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
