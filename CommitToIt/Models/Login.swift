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
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case username
        case accessToken
        case refreshToken
    }

}
