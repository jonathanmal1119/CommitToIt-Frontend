//
//  Reward 2.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//


struct Reward: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var cost: Int
    var icon: String
    var redeemed_at: Date?
}