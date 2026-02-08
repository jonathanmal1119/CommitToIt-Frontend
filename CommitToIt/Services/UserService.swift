//
//  UserService.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/3/26.
//

import Foundation

final class UserService {
    
    static func fetchUserStats(user_id: Int) async throws -> UserStats {
        let data = try await APIClient.request(
            urlString: "/user/user-stats?user_id=\(user_id)",
            method: "GET"
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(UserStatsResponse.self, from: data)

        return response.data
    }
    
}
