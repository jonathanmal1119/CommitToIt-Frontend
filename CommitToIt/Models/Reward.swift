//
//  Reward.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//
import Foundation

//Requests
struct RewardRequest: Encodable {
    let user_id: Int
    let reward_id: Int
}

struct RedeemRewardRequest: Encodable {
    let user_id: Int
    let user_reward_id: Int
}

// PurchaseAbleResponse
struct PurchaseableRewardResponse: Decodable {
    let status: String
    let message: String
    let data: [PurchaseableReward]?
}

struct PurchaseableReward: Identifiable, Codable, Equatable {
    var id: Int
    var title: String
    var description: String
    var cost: Int
    var icon: String
    var earned_at: Date?
    var redeemed_at: Date?
    var filter: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "reward_id"
        case title = "title"
        case description = "description"
        case cost = "cost"
        case icon = "icon"
        case earned_at = "earned_at"
        case redeemed_at = "redeemed_at"
        case filter = "filter"
    }
}

// User Reward
struct UserRewardResponse: Decodable {
    let status: String
    let message: String
    let data: [UserReward]
}

struct UserReward: Identifiable, Codable, Equatable {
    var id: Int
    var title: String
    var description: String
    var cost: Int
    var icon: String
    var earned_at: Date?
    var redeemed_at: Date?
    var fulfilled_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_reward_id"
        case title = "title"
        case description = "description"
        case cost = "cost"
        case icon = "icon"
        case earned_at = "earned_at"
        case redeemed_at = "redeemed_at"
        case fulfilled_at = "fullfilled_at"
    }
}


