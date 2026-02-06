//
//  UserService.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/3/26.
//

import Foundation

final class UserService {
    
    static func login(
        email: String,
        password: String
    ) async throws {

        let body = try JSONEncoder().encode(
            LoginRequest(email: email, password: password)
        )

        let data = try await APIClient.request(
            urlString: "/user/login",
            method: "POST",
            body: body
        )

        let decoder = JSONDecoder()
        let response = try decoder.decode(LoginResponse.self, from: data)

        AuthManager.shared.saveTokens(
            access: response.data.accessToken,
            refresh: response.data.refreshToken
        )
        
        
        AppState.shared.setUserId(response.data.userId)
        AppState.shared.setUserInfo(UserInfo(
            username: response.data.username,
            email: response.data.email
        ))
        
        AppState.shared.selectedTab = .home
    }
    
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
