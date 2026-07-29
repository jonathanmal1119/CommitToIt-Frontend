//
//  AdminUserLookup.swift
//  CommitToIt
//

import Foundation

struct AdminUserLookupResponse: Decodable {
    let status: String
    let message: String
    let data: AdminUserLookupData
}

struct AdminUserLookupData: Decodable, Equatable {
    let user_id: Int
    let email: String
    let username: String
    let stats: UserStats
    let unredeemed_rewards: [UserReward]
}
