//
//  Login.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/4/26.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let status: String
    let message: String
    let data: LoginData
}

struct LoginData: Decodable {
    let userId: Int
    let email: String
    let username: String
    let isAdmin: Bool
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case username
        case isAdmin = "is_admin"
        case accessToken
        case refreshToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(Int.self, forKey: .userId)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin) ?? false
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}
