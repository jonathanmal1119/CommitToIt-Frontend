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
    static let shared = AppState(load_mock_data: false)
    
    // MARK: - Current App Tab
    @Published var selectedTab: Tabs = .login
    
    // MARK: - Server Data
    @Published private(set) var redeemable_rewards: [Reward] = []
    
    // MARK: - Core User Data
    @Published private(set) var user_tasks: [TaskItem] = []
    @Published private(set) var user_rewards: [Reward] = []
    
    // MARK: - History
    //@Published private(set) var user_redeemed_rewards: [Reward] = []
    @Published private(set) var user_completed_tasks: [TaskItem] = []

    // MARK: - Stats
    @Published private(set) var user_stats: UserStats
    @Published private(set) var user_id: Int = -1
    @Published private(set) var user_info: UserInfo

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: Auth
    @Published var isAuthenticated = false
    
    init(load_mock_data: Bool) {
        
        self.redeemable_rewards = [
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 2, title: "Test Reward", description: "Mock Data", cost: 100, icon: "fork.knife"),
            Reward(id: 3, title: "Test Reward", description: "Mock Data", cost: 100, icon: "gamecontroller.fill"),
            Reward(id: 4, title: "Test Reward", description: "Mock Data but this needs tio be a really long desc so i can fully test it", cost: 100, icon: "cart.badge.clock.fill"),
            Reward(id: 5, title: "Test Reward", description: "Mock Data", cost: 100, icon: "bag.fill"),
            Reward(id: 6, title: "Test Reward", description: "Mock Data", cost: 100, icon: "bag.fill.badge.plus")
        ]
        
        self.user_tasks = [
            TaskItem(id: 0, title: "Add eUser Logins", description: "Preview description buddy",point_value: 10, completed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), filter: "pending"),
        ]
        
        self.user_rewards = [
//            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
//            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
//            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
        ]
        
        self.user_stats = .init(
            point_balance: 0,
            completed_tasks: 0,
            redeemed_rewards: 0,
            total_points_earned: 0,
        )
        
        self.user_id = -1
        
        self.user_info = .init(
            username: "",
            email: ""
        )
    }
    
    static var mock: AppState {
        AppState(load_mock_data: false)
    }
    
    func signOut() {
        selectedTab = .login
        isAuthenticated = false
            
        redeemable_rewards = []
        user_tasks = []
        user_rewards = []
            
        user_stats = UserStats(
            point_balance: 0,
            completed_tasks: 0,
            redeemed_rewards: 0,
            total_points_earned: 0
        )
        
        user_id = -1
        user_info = UserInfo(username: "", email: "")
            
        isLoading = false
        errorMessage = nil
    }
    
    func syncAuthState() {
        isAuthenticated = AuthManager.shared.isAuthenticated
    }
    
    // Sync Functions
    
    func setRedeemableRewards(_ rewards: [Reward]) {
        self.redeemable_rewards = rewards
    }
    
    func setUserRewards(_ rewards: [Reward]) {
        self.user_rewards = rewards
    }
    
    func setUserTasks(_ tasks: [TaskItem]) {
        self.user_tasks = tasks
    }
    
    func setUserStats(_ userStats: UserStats) {
        self.user_stats = userStats
    }
    
    func setUserId(_ userID: Int) {
        self.user_id = userID
    }
    
    func setUserInfo(_ userInfo: UserInfo) {
        self.user_info = userInfo
    }
    
    func setUserCompletedTasks(_ tasks: [TaskItem]) {
        self.user_completed_tasks = tasks
    }
    
    func addTask(_ task: TaskItem) {
        self.user_tasks.insert(task, at: 0)
    }
    
    func removeTask(id: Int) {
        self.user_tasks.removeAll { $0.id == id }
    }
    
    func addUserReward(_ reward: Reward) {
        self.user_rewards.insert(reward, at: 0)
        self.user_stats.point_balance -= reward.cost
        self.user_stats.redeemed_rewards += 1
    }
    
    func removeUserReward(id: Int) {
        self.user_rewards.removeAll { $0.id == id }
    }
    
    func addCompletedTask(_ task: TaskItem) {
        self.user_completed_tasks.insert(task, at: 0)
    }
    
}
