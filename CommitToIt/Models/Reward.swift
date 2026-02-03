//
//  Reward.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//
import Foundation

struct RewardResponse: Decodable {
    let status: String
    let message: String
    let data: [Reward]
}

struct Reward: Identifiable, Codable, Equatable {
    var id: Int
    var title: String
    var description: String
    var cost: Int
    var icon: String
    var earned_at: Date?
    var redeemed_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "reward_id"
        case title
        case description
        case cost
        case icon
        case earned_at
        case redeemed_at
    }
}

