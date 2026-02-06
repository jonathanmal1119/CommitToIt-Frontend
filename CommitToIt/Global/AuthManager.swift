//
//  AuthManager.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/4/26.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private let keychain = KeychainService()
    private(set) var accessToken: String?
    
        
    private init() {
        accessToken = keychain.get("access_token")
    }
    
    var isAuthenticated: Bool {
        accessToken != nil
    }
    
    func saveTokens(access: String, refresh: String) {
        accessToken = access
        keychain.set(access, forkey: "access_token")
        keychain.set(refresh, forkey: "refresh_token")
    }
    
    func clearTokens() {
        accessToken = nil
        keychain.delete("access_token")
        keychain.delete("refresh_token")
    }
    
    func getRefreshToken() -> String? {
        keychain.get("refresh_token")
    }
}
