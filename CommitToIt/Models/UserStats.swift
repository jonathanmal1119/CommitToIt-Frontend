//
//  UserStats.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//
import Foundation

struct UserStats : Codable, Equatable {
    var completed_tasks: Int
    var redeemed_rewards: Int
    var total_points_earned: Int
    var completed_projects: Int
}
