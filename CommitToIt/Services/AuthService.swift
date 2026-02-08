//
//  AuthService.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/6/26.
//
import Foundation

final class AuthService {
    
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
    
    static func logout() {
        AuthManager.shared.clearTokens()
        
        AppState.shared.signOut()
    }
}
