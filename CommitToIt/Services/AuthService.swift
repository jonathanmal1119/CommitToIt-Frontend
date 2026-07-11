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
    
    static func signup(
        email: String,
        password: String,
        username: String
    ) async throws {
        
        let body = try JSONEncoder().encode(
            SignUpRequest(email: email, password: password, username: username)
        )

        let data = try await APIClient.request(
            urlString: "/user/signup",
            method: "POST",
            body: body
        )
    
        let decoder = JSONDecoder()
        let response = try decoder.decode(SignUpResponse.self, from: data)

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

    /// Permanently deletes the signed-in user's account server-side, then
    /// clears local session state. Required by App Store Review Guideline
    /// 5.1.1(v): any app that supports account creation must let the user
    /// delete their account from within the app.
    static func deleteAccount() async throws {
        let body = try JSONEncoder().encode(
            DeleteAccountRequest(user_id: AppState.shared.user_id)
        )

        let data = try await APIClient.request(
            urlString: "/user/delete-account",
            method: "DELETE",
            body: body
        )

        let response = try JSONDecoder().decode(DeleteAccountResponse.self, from: data)

        guard response.status == "OK" else {
            throw APIError.httpStatus(0)
        }

        AuthManager.shared.clearTokens()
        AppState.shared.signOut()
    }
}

