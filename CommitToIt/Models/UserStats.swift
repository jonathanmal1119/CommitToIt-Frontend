//
//  UserStats.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//
import Foundation

struct UserStatsResponse: Decodable {
    let status: String
    let message: String
    let data: UserStats
}

struct UserStats : Codable, Equatable {
    var point_balance: Int
    var completed_tasks: Int
    var redeemed_rewards: Int
    var total_points_earned: Int
    
    enum CodingKeys: String, CodingKey {
        case point_balance = "point_balance"
        case completed_tasks = "completed_tasks"
        case redeemed_rewards = "redeemed_rewards"
        case total_points_earned = "total_points_earned"
    }
}
