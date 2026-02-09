//
//  LoginView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var password = "tttttt"
    @State private var email = "t@t.com"
    
    @State private var errorDisplay: Bool = false
    
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
            
            VStack(spacing: 10) {
                VStack {
                    ZStack {

                        Text("Commit To It")
                            .font(.system(size: 40)).bold()
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .trailing, vertical: .top))
                    .padding(10)
                    .background(.background)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20)
                }
                
                VStack (alignment: .leading) {
                    
                    Text("Sign In")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal,10)
                        .padding(.bottom, 50)
                        .padding(.top, 20)
                        .background(.background)
                    
                    ZStack (alignment: .topLeading) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                            .border(.red, width: errorDisplay ? 1 : 0)
                            .animation(.easeInOut(duration: 0.1), value: errorDisplay)
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
                            .border(.red, width: errorDisplay ? 1 : 0)
                            .animation(.easeInOut(duration: 0.1), value: errorDisplay)
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
                                topLeading: 10,
                                bottomLeading: 10,
                                bottomTrailing: 10,
                                topTrailing: 10
                            ))
                            //.fill(.accent.opacity(0.8))
                            .fill(errorDisplay ? .red : Color(.systemBlue))
                            .animation(.easeInOut(duration: 0.1), value: errorDisplay)
                            .frame(maxHeight: 50)
                            
                            Text("Sign In")
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
                try await AuthService.login(email: email, password: password)
                
                if AuthManager.shared.isAuthenticated {
                    appState.selectedTab = .home
                    await syncHomeData()
                }
            } catch {
                //print("[Sign In Error] \(error.localizedDescription)")
                errorDisplay = true
                try await Task.sleep(nanoseconds: 1_000_000_000)
                errorDisplay = false
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
            print("[FetchAvailableRewards] \(error)")
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
            let taskResponse = try await TaskService.fetchUserTasks()

            appState.setUserTasks(taskResponse)
            
            let completedTasksResponse = try await TaskService.fetchCompletedUserTasks()
            
            appState.setUserCompletedTasks(completedTasksResponse)
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

