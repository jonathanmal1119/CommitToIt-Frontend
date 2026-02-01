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
    
    // MARK: - API INFO
    @Published var baseURL: String = "http://api.committoit.click/api"
    
    // MARK: - Server Data
    @Published private(set) var redeemable_rewards: [Reward] = []
    
    // MARK: - Core User Data
    @Published private(set) var user_tasks: [Task] = []
    @Published private(set) var user_rewards: [Reward] = []
    
    // MARK: - Progress
    @Published private(set) var points: Int = 0

    // MARK: - Stats
    @Published private(set) var user_stats: UserStats
    @Published private(set) var user_id: UserID

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    //private let taskRepository = TaskRepository()
    //private let rewardRepository = RewardRepository()
    //private let statsRepository = StatsRepository()
    
    init(load_mock_data: Bool) {

        //guard load_mock_data else { return nil }
        
        self.redeemable_rewards = [
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill"),
            Reward(id: 1, title: "Test Reward", description: "Mock Data", cost: 100, icon: "mug.fill")
        ]
        
        self.user_tasks = [
            Task(id: 0, title: "Add User Logins", point_value: 100, icon: "mug.fill", project_id: 1, project_name: "Meal Prep"),
            Task(id: 1, title: "Preview", point_value: 100, icon: "mug.fill", project_id: 2, project_name: "Project 21"),
            Task(id: 2, title: "Preview", point_value: 100, icon: "mug.fill", project_id: nil, project_name: nil),
            Task(id: 3, title: "Preview", point_value: 100, icon: "mug.fill", project_id: nil, project_name: nil),
            Task(id: 4, title: "Preview", point_value: 100, icon: "mug.fill", project_id: nil, project_name: nil)
        ]
        
        self.user_rewards = [
            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
            Reward(id: 1, title: "Free Starbucks Drink", description: "1 Free drink of your choice", cost: 100, icon: "mug.fill", earned_at: Calendar.current.date(byAdding: .day, value: -1, to: Date()), redeemed_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
            
        ]
        
        self.points = 0
        
        self.user_stats = .init(
            completed_tasks: 0,
            redeemed_rewards: 1,
            total_points_earned: 100,
            completed_projects: 10,
        )
        
        self.user_id = .init(
            first_name: "Jonathan",
            last_name: "Malave",
        )
        
    }
    
    static var mock: AppState {
        AppState(load_mock_data: true)
    }
    
    func add(points: Int) {
        self.points += points
    }
    
    func remove(points: Int) {
        self.points = max(self.points - points, 0)
    }
    
}
