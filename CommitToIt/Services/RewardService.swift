//
//  RewardService.swift
//  APITester
//
//  Created by Jonathan Malave on 2/2/26.
//

import Foundation

final class RewardService {
    
    static func fetchAvailableRewards() async throws -> [PurchaseableReward] {
        let data = try await APIClient.request(
            urlString: "/reward/redeemable-rewards",
            method: "GET"
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(PurchaseableRewardResponse.self, from: data)

        return response.data ?? []
    }
    
    static func fetchUserRewards(user_id: Int) async throws -> [UserReward] {
        let data = try await APIClient.request(
            urlString: "/reward/user-rewards-history?user_id=\(user_id)",
            method: "GET"
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(UserRewardResponse.self, from: data)
        
        return response.data
    }
    
    static func purchaseAvailableReward(reward_id: Int) async throws -> [UserReward] {
        let body = RewardRequest(user_id: AppState.shared.user_id, reward_id: reward_id)
        let encodedBody = try JSONEncoder().encode(body)
        
        let data = try await APIClient.request(
            urlString: "/reward/purchase",
            method: "POST",
            body: encodedBody
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(UserRewardResponse.self, from: data)
        
        return response.data
    }
    
    static func redeemAvailableReward(user_reward_id: Int) async throws -> Bool {
        let body = RedeemRewardRequest(user_id: AppState.shared.user_id, user_reward_id: user_reward_id)
        let encodedBody = try JSONEncoder().encode(body)
        
        let data = try await APIClient.request(
            urlString: "/reward/redeem",
            method: "POST",
            body: encodedBody
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(UserRewardResponse.self, from: data)
        
        return response.status == "OK" ? true : false
    }
    
}

