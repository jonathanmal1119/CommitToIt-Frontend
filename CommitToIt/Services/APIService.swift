//
//  APIClient.swift
//  APiTester
//
//  Created by Jonathan Malave on 2/2/26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
}

final class APIClient {
    private static let baseURL: String = "https://api.committoit.click/api"

    static func request(
        urlString: String,
        method: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil,
    ) async throws -> Data {
        

        guard let url = URL(string: baseURL + urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = AuthManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return data
        }

        if (httpResponse.statusCode == 401) {
            let refreshed = try await refreshAccessToken()
            
            if refreshed {
                return try await self.request(
                    urlString: urlString,
                    method: method,
                    headers: headers,
                    body: body,
                )
            }
        }

        return data
    }
    
    static func refreshAccessToken() async throws -> Bool {

        print("Refreshing Token")
        
        guard let refreshToken = AuthManager.shared.getRefreshToken() else {
            throw APIError.httpStatus(401)
        }

        let body = try JSONEncoder().encode(
            AuthRequest(refreshToken: refreshToken)
        )

        do {
            let data = try await request(
                urlString: "/user/refresh",
                method: "POST",
                body: body,
            )

            let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
            
            AuthManager.shared.refreshAccessToken(new_accessToken: decoded.accessToken)

            return true
        } catch {
            print("[RefreshToken] \(error)")
            AuthManager.shared.clearTokens()
            AppState.shared.signOut()
            return false
        }
    }


}
