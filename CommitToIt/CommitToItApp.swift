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
                    //appState.syncAuthState()
                    //await runStartUpSync()
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

            appState.selectedTab = .home
                
            try await fetchTasks()
            try await fetchRewards()
            //try await fetchUser()
        }
        catch {
            print("Error Sync Failed")
        }
    }
    
    func fetchTasks() async throws {
        do {
            let taskResponse = try await TaskService.fetchUserTasks()

            AppState.shared.setUserTasks(taskResponse)
        } catch {
            print("[FetchTasks] \(error.localizedDescription)")
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
    
    
    
    
}
