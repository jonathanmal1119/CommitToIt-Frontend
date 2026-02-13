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
    private let keychain = KeychainService()
    
    // MARK: - Current App Tab
    @Published var selectedTab: Tabs = .login
    
    // MARK: - Server Data
    @Published private(set) var redeemable_rewards: [PurchaseableReward] = []
    
    // MARK: - Core User Data
    @Published private(set) var user_tasks: [TaskItem] = []
    @Published private(set) var user_rewards: [UserReward] = []
    
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
//            PurchaseableReward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
//            PurchaseableReward(id: 2, title: "Test Reward", description: "Mock Data", cost: 100, icon: "fork.knife"),
//            PurchaseableReward(id: 3, title: "Test Reward", description: "Mock Data", cost: 100, icon: "gamecontroller.fill"),
//            PurchaseableReward(id: 4, title: "Test Reward", description: "Mock Data but this needs tio be a really long desc so i can fully test it", cost: 100, icon: "cart.badge.clock.fill"),
//            PurchaseableReward(id: 5, title: "Test Reward", description: "Mock Data", cost: 100, icon: "bag.fill"),
//            PurchaseableReward(id: 6, title: "Test Reward", description: "Mock Data", cost: 100, icon: "bag.fill.badge.plus")
        ]
        
        self.user_tasks = [
            TaskItem(id: 0, title: "Add eUser Logins", description: "Preview description buddy",point_value: 10, completed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), filter: "pending"),
        ]
        
        self.user_rewards = [
//            UserReward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
//            UserReward(id: 2, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: nil),
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
        
        if isAuthenticated {
            let retrieved_key = keychain.get("user_id")
            self.user_id = Int(retrieved_key ?? "") ?? -1
        }
    }
    
    // Sync Functions
    
    func setRedeemableRewards(_ rewards: [PurchaseableReward]) {
        self.redeemable_rewards = rewards
    }
    
    func setUserRewards(_ rewards: [UserReward]) {
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
        
        keychain.set(String(self.user_id), forkey: "user_id")
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
    
    func addUserReward(_ reward: UserReward) {
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
    
    func markRewardAsRedeemed(rewardId: Int) {
        if let index = self.user_rewards.firstIndex(where: { $0.id == rewardId }) {
            self.user_rewards[index].redeemed_at = Date()
        } else {
            print("markRewardAsRedeemed: reward with id \(rewardId) not found")
        }
    }
    
}
