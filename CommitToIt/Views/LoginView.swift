//
//  LoginView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var tab : StartupTabs = .signup
    
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
                
                VStack {
                    HStack (spacing: 20) {
                        Button {
                            tab = .login
                        } label: {
                            VStack {
                                Text("Login")
                                    .font(.headline)
                                    .foregroundColor(.primary.opacity(tab == .login ? 1 : 0.3))
                                    .padding(.horizontal, 10)
                                    .cornerRadius(10)
                                    .padding(.vertical, 5)
                                    .animation(.easeInOut, value: 0.6)
                                    
                                
                                Color.primary
                                    .opacity(tab == .login ? 1 : 0.3)
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                    .animation(.easeInOut, value: 0.6)
                            }
                        }
                        
                        Button {
                            tab = .signup
                        } label: {
                            VStack {
                                Text("Sign Up")
                                    .font(.headline)
                                    .foregroundColor(.primary.opacity(tab == .signup ? 1 : 0.3))
                                    .padding(.horizontal, 10)
                                    .cornerRadius(10)
                                    .padding(.vertical, 5)
                                    .animation(.easeInOut, value: 0.6)
                                
                                Color.primary
                                    .opacity(tab == .signup ? 1 : 0.3)
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                    .animation(.easeInOut, value: 0.6)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .padding(.bottom, 10)
                    
                    Group {
                        switch tab {
                            case .login:
                                LoginPageView()
                            case .signup:
                                SignUpPageView()
                            }
                    }
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

struct LoginPageView: View {
    @State private var login_password = "tttttt"
    @State private var login_email = "t@t.com"
        
    @State private var errorDisplay: Bool = false
        
    var body: some View {
        VStack (spacing: 20) {
            ZStack (alignment: .topLeading) {
                TextField("Email", text: $login_email)
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
                SecureField("Password", text: $login_password)
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
                    .fill(errorDisplay ? .red : .blue)
                    .animation(.easeInOut(duration: 0.1), value: errorDisplay)
                    .frame(maxHeight: 50)
                        
                    Text("Login")
                        .foregroundStyle(.white)
                        .font(.title3.bold())
                }
                    
            }
            .padding(10)
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity)
        }
    }
        
    func login() {
        Task {
            do {
                try await AuthService.login(email: login_email, password: login_password)
            } catch {
                errorDisplay = true
                try await Task.sleep(nanoseconds: 1_000_000_000)
                errorDisplay = false
            }
        }
    }
}

struct SignUpPageView: View {
    
    @State private var signup_password = ""
    @State private var signup_email = ""
    @State private var signup_username = ""
    
    @State private var errorDisplay: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack (spacing: 20) {
            ZStack (alignment: .topLeading) {
                TextField("Username", text: $signup_username)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                    .border(.red, width: errorDisplay ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: errorDisplay)
                    .padding(.top, 7)
                
                Text("Username")
                    .font(.caption)
                    .padding([.leading, .trailing], 4)
                    .background(.background)
                    .padding(.leading, 5)
            }
            .padding(.horizontal, 10)
        
            ZStack (alignment: .topLeading) {
                TextField("Email", text: $signup_email)
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
                
                VStack (alignment: .leading) {
                    SecureField("Password", text: $signup_password)
                        .textFieldStyle(.roundedBorder)
                        .border(.red, width: errorDisplay ? 1 : 0)
                        .animation(.easeInOut(duration: 0.1), value: errorDisplay)
                        .padding(.vertical, 7)
                    
                    Text(errorMessage)
                        .padding(.leading, 7)
                        
                }
                
                Text("Password")
                    .font(.caption)
                    .padding([.leading, .trailing], 4)
                    .background(.background)
                    .padding(.leading, 5)
                
            }
            .padding(.horizontal, 10)
            
            
        
            Button() {
                signup(user_name: signup_username, password: signup_password, email: signup_email)
            } label: {
                ZStack {
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 10,
                        bottomLeading: 10,
                        bottomTrailing: 10,
                        topTrailing: 10
                    ))
                    .fill(errorDisplay ? .red : .blue)
                    .animation(.easeInOut(duration: 0.1), value: errorDisplay)
                    .frame(maxHeight: 50)
                    
                    Text("Sign Up")
                        .foregroundStyle(.white)
                        .font(.title3.bold())
                }
                
            }
            .padding(10)
            .padding(.top, -10)
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity)
        }
    }
    
    func signup(user_name: String, password: String, email: String) {
        
        
        
        Task {
            do {
                guard !user_name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    errorMessage = "Username cannot be empty"
                    errorDisplay = true
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    errorDisplay = false
                    errorMessage = ""
                    return
                }
                
                guard email.range(
                    of: #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#,
                    options: .regularExpression
                ) != nil else {
                    errorMessage = "Invalid email address"
                    errorDisplay = true
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    errorDisplay = false
                    errorMessage = ""
                    return
                }
                
                guard password.count >= 6 else {
                    errorMessage = "Password must be at least 6 characters"
                    errorDisplay = true
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    errorDisplay = false
                    errorMessage = ""
                    return
                }
                
                try await AuthService.signup(email: signup_email, password: signup_password, username: signup_username)
            } catch {
                print("[SignUpError] \(error)")
                
                errorDisplay = true
                errorMessage = "Error Signing Up. Try again later"
                try await Task.sleep(nanoseconds: 1_000_000_000)
                errorDisplay = false
                errorMessage = ""
            }
            
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState(load_mock_data: true))
}

