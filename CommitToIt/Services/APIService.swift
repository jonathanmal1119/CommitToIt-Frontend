//
//  APIService.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 2/1/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response."
        case .httpStatus(let code):
            return "Server returned error: \(code)"
        case .decodingFailed(let underlying):
            return "Failed to decode JSON: \(underlying.localizedDescription)"
        }
    }
}

struct APIService {
    
    // MARK: API vars
    private var baseURL: String = "http://api.committoit.click/api"
    
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        token: String? = nil
    )
    async throws -> T {
        
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badServerResponse)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error)
        }
    }
}
