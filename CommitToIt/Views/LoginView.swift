//
//  HistoryView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var password = "tttttt"
    @State private var email = "t@t.com"
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.627, green: 0.761, blue: 0.455, opacity: 1),
                    Color(red: 0.741, green: 0.91, blue: 0.522, opacity: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                
                VStack (alignment: .leading) {
                    
                    
                    Text("Login")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal,10)
                        .padding(.bottom, 40)
                        .padding(.top, 20)
                        .background(.background)
                
                    
                    ZStack (alignment: .topLeading) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 7)
                        
                        Text("Email")
                            .font(.caption)
                            .padding([.leading, .trailing], 4)
                            .background(.background)
                            .padding(.leading, 5)
                    }
                    .padding(.horizontal, 10)

                    
                    ZStack (alignment: .topLeading) {
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 7)
                        
                        Text("Password")
                            .font(.caption)
                            .padding([.leading, .trailing], 4)
                            .background(.background)
                            .padding(.leading, 5)
                        
                    }
                    .padding(.horizontal, 10)
                    .padding(.top,20)
                    
                    Button() {
                        login()
                    } label: {
                        ZStack {
                            UnevenRoundedRectangle(cornerRadii: .init(
                                topLeading: 20,
                                bottomLeading: 20,
                                bottomTrailing: 20,
                                topTrailing: 20
                            ))
                            //.fill(.accent.opacity(0.8))
                            .frame(maxHeight: 50)
                        
                            Text("Login")
                                .foregroundStyle(.white)
                                .font(.title3.bold())
                        }
                        
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .trailing, vertical: .top))
                .padding(10)
                .background(.background)
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(20)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func login() {
        Task {
            do {
                try await UserService.login(email: email, password: password)
                
                if AuthManager.shared.isAuthenticated {
                    appState.selectedTab = .home
                    await syncHomeData()
                }
            }
            
        }
    }
    
    func syncHomeData() async {
        do {
            try await fetchRewards()
            try await fetchTasks()
            try await fetchUserData()
            
            appState.selectedTab = .home
        }
        catch {
            print("Error Sync Failed")
        }
    }

    
    func fetchRewards() async throws {
        do {
            let availableRewardsResponse = try await RewardService.fetchAvailableRewards()

            appState.setRedeemableRewards(availableRewardsResponse)
        } catch {
            print("[FetchAvailableRewards] \(error.localizedDescription)")
        }
        
        do {
            let userRewardsResponse = try await RewardService.fetchUserRewards(user_id: appState.user_id)

            appState.setUserRewards(userRewardsResponse)
        } catch {
            print("[FetchUserRewards] \(error.localizedDescription)")
        }

    }
    
    func fetchTasks() async throws {
        do {
            let taskResponse = try await TaskService.fetchUserTasks(user_id: appState.user_id)

            appState.setUserTasks(taskResponse)
        } catch {
            print("[FetchTasks] \(error.localizedDescription)")
        }

    }
    
    func fetchUserData() async throws {
        do {
            let userResponse = try await UserService.fetchUserStats(user_id: appState.user_id)
            
            appState.setUserStats(userResponse)
        } catch {
            print("[FetchUserStats] \(error.localizedDescription)")
        }
    }
    
}

#Preview {
    LoginView()
        .environmentObject(AppState(load_mock_data: true))
}

