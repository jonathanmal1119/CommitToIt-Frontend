//
//  TaskService.swift
//  APiTester
//
//  Created by Jonathan Malave on 2/2/26.
//

import Foundation

final class TaskService {
    
    static func fetchUserTasks(user_id: Int) async throws -> TaskResponse {
        let data = try await APIClient.request(
            urlString: "/task?user_id=\(user_id)",
            method: "GET"
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponse.self, from: data)

        return response
    }
    
}

