//
//  CommitToItApp.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/25/26.
//

import SwiftUI

@main
struct CommitToItApp: App {
    @StateObject var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await runStartUpSync()
                }
        }
    }
    
    func runStartUpSync() async {
        do {
            appState.syncAuthState()
            
            if (appState.isAuthenticated == false){
                return
            }
            
            print("Authed")
            print(appState.user_id)

            appState.selectedTab = .home
                
            try await fetchRewards()
            try await fetchTasks()
            try await fetchUserData()
        }
        catch {
            print("Error Sync Failed")
        }
    }

    func fetchRewards() async throws {
        do {
            let availableRewardsResponse = try await RewardService.fetchAvailableRewards()

            AppState.shared.setRedeemableRewards(availableRewardsResponse)
        } catch {
            print("[FetchAvailableRewards] \(error)")
        }
        
        do {
            let userRewardsResponse = try await RewardService.fetchUserRewards(user_id: AppState.shared.user_id)

            AppState.shared.setUserRewards(userRewardsResponse)
        } catch {
            print("[FetchUserRewards] \(error.localizedDescription)")
        }

    }

    func fetchTasks() async throws {
        do {
            let taskResponse = try await TaskService.fetchUserTasks()

            AppState.shared.setUserTasks(taskResponse)
            
            let completedTasksResponse = try await TaskService.fetchCompletedUserTasks()
            
            AppState.shared.setUserCompletedTasks(completedTasksResponse)
        } catch {
            print("[FetchTasks] \(error.localizedDescription)")
        }

    }

    func fetchUserData() async throws {
        do {
            let userResponse = try await UserService.fetchUserStats(user_id: AppState.shared.user_id)
            
            AppState.shared.setUserStats(userResponse)
        } catch {
            print("[FetchUserStats] \(error.localizedDescription)")
        }
    }
}
