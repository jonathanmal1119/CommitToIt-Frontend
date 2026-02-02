//
//  Reward.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//
import Foundation

struct Reward: Identifiable, Codable, Equatable {
    var id: Int
    var title: String
    var description: String
    var cost: Int
    var icon: String
    var earned_at: Date?
    var redeemed_at: Date?
}

