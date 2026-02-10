//
//  LoginRequest.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/9/26.
//


//
//  Login.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/4/26.
//

import Foundation

struct SignUpRequest: Codable {
    let email: String
    let password: String
    let username: String
}

struct SignUpResponse: Decodable {
    let status: String
    let message: String
    let data: SignUpData
}

struct SignUpData: Decodable {
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
