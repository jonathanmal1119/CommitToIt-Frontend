//
//  HomePageView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/26/26.
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack{
            LinearGradient(
                colors: [
                    Color(red: 0.627, green: 0.761, blue: 0.455, opacity: 1),
                    Color(red: 0.741, green: 0.91, blue: 0.522, opacity: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack (spacing: 10){
                ZStack {
                    Image(systemName: "checklist")
                        .foregroundStyle(.primary)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Commit To It")
                        .font(.system(size: 40)).bold()
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    
                    Button() {
                        AuthService.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.red.opacity(0.8))
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .trailing, vertical: .top))
                .padding(10)
                .background(.background)
                .cornerRadius(15)
                .shadow(radius: 10)
                
                ZStack{
                    ProgressBarView()
                }
                .padding(10)
                .background(.background)
                .cornerRadius(15)
                .shadow(radius: 10)

                
                // MARK: Today's Tasks
                VStack() {
                    HStack {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.accent)
                            .font(.system(size: 25))
                    
                        Text("Today's Tasks")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            appState.selectedTab = .tasks
                        } label : {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.accent)
                                .font(.system(size: 20))
                        }
                        
                    }
                    .padding([.top,.leading,.trailing], 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Color.primary.opacity(0.1).frame(height: 1)
                    
                    TaskListView(show_create_new_task: .constant(false))
                        .padding(.top, -8)
                }
                .background(.background)
                .cornerRadius(15)
                .shadow(radius: 10)
 
                
                // MARK: Available Rewards
                if appState.user_rewards.filter({ $0.redeemed_at == nil }).count > 0 {
                    VStack() {
                        
                        HStack {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.accent)
                                .font(.system(size: 25))
                        
                            Text("\(appState.user_rewards.filter({ $0.redeemed_at == nil }).count) Available Rewards")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button {
                                appState.selectedTab = .history
                            } label : {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.accent)
                                    .font(.system(size: 20))
                            }
                            
                        }
                        .padding([.top,.leading,.trailing], 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Color.primary.opacity(0.1).frame(height: 1)
                        
                        RewardsListView(showAdvancedInfo: false, showUnclaimedRewards: true)
                            .padding(.top, -8)
                    }
                    .background(.background)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .frame(maxHeight: 160)
                }
            }
            .padding(20)
            .padding(.bottom, 50)
                
        }
    }
}

#Preview {
    HomePageView()
        .environmentObject(AppState.shared)
}

