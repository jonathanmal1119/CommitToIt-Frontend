//
//  Auth.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/10/26.
//

import Foundation

struct AuthRequest: Codable {
    let refreshToken: String
}

struct AuthResponse: Decodable {
    let status: String
    let message: String
    let accessToken: String
}

struct DeleteAccountRequest: Codable {
    let user_id: Int
}

struct DeleteAccountResponse: Decodable {
    let status: String
    let message: String
}
