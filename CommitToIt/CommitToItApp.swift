//
//  CommitToItApp.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/25/26.
//

import SwiftUI

@main
struct CommitToItApp: App {
    @StateObject var appState = AppState(load_mock_data: true)
    
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
            try await fetchTasks()
            try await fetchRewards()
            try await fetchUser()
        }
        catch {
            print("Error Sync Failed")
        }
    }
    
    func fetchTasks() async throws {
        // get user tasks
    }
    
    func fetchRewards() async throws {
        do {
            let response = try await RewardService.fetchAvailableRewards()

            appState.setRedeemableRewards(response)
        } catch {
            print(error.localizedDescription)
        }
        // update user rewards
    }
    
    func fetchUser() async throws {
        do {
            let response = try await UserService.fetchUserStats(user_id: appState.user_id)

            appState.setUserStats(response.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}
