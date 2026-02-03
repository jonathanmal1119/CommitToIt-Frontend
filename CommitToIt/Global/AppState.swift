//
//  AppState.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    
    // MARK: - Current App Tab
    @Published var selectedTab: Tabs = .home
    
    // MARK: - Server Data
    @Published private(set) var redeemable_rewards: [Reward] = []
    
    // MARK: - Core User Data
    @Published private(set) var user_tasks: [TaskItem] = []
    @Published private(set) var user_rewards: [Reward] = []

    // MARK: - Stats
    @Published private(set) var user_stats: UserStats
    @Published private(set) var user_id: Int = -1

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(load_mock_data: Bool) {
        
        self.redeemable_rewards = [
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 2, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 3, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 4, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 5, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill")
        ]
        
        self.user_tasks = [
            TaskItem(id: 0, title: "Add User Logins", description: "Preview description buddy",point_value: 10, completed_at: nil, filter: "pending"),
            TaskItem(id: 0, title: "Test 1", description: "Preview description buddy",point_value: 10, completed_at: nil, filter: "pending"),
            TaskItem(id: 0, title: "Add User Logins", description: "Preview description buddy",point_value: 10, completed_at: nil, filter: "pending"),
            TaskItem(id: 0, title: "Add User Logins", description: "Preview description buddy",point_value: 10, completed_at: nil, filter: "pending"),
            TaskItem(id: 0, title: "Add User Logins", description: "Preview description buddy",point_value: 10, completed_at: nil, filter: "pending"),
            TaskItem(id: 0, title: "Add User Logins", description: "Preview description buddy",point_value: 10, completed_at: nil, filter: "pending"),
        ]
        
        self.user_rewards = [
            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
            
        ]
        
        self.user_stats = .init(
            point_balance: 100,
            completed_tasks: 0,
            redeemed_rewards: 1,
            total_points_earned: 100,
        )
        
        self.user_id = 2
    }
    
    static var mock: AppState {
        AppState(load_mock_data: false)
    }
    
    // Sync Functions
    
    func setRedeemableRewards(_ rewards: [Reward]) {
        self.redeemable_rewards = rewards
    }
    
    func setUserTasks(_ tasks: [TaskItem]) {
        self.user_tasks = tasks
    }
    
    func setUserStats(_ userStats: UserStats) {
        self.user_stats = userStats
    }
    
}
