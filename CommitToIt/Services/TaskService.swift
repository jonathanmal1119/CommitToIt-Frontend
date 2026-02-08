//
//  TaskService.swift
//  APiTester
//
//  Created by Jonathan Malave on 2/2/26.
//

import Foundation

final class TaskService {
    
    static func fetchUserTasks() async throws -> [TaskItem] {
        let data = try await APIClient.request(
            urlString: "/task?user_id=\(AppState.shared.user_id)",
            method: "GET"
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponse.self, from: data)
        
        return response.data ?? []
    }
    
    static func createTask(title: String, description: String?, point_value: Int) async throws -> [TaskItem] {
        
        let body = AddTaskRequest(user_id: AppState.shared.user_id, title: title, description: description, point_value: point_value)
        let encodedBody = try JSONEncoder().encode(body)
        
        let data = try await APIClient.request(
            urlString: "/task/add-task",
            method: "POST",
            body: encodedBody
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponse.self, from: data)
        
        return response.data ?? []
    }
    
    static func markTaskCompleted(task_id: Int) async throws -> Bool {
        let body = MarkTaskCompletedRequest(user_id: AppState.shared.user_id, task_id: task_id)
        let encodedBody = try JSONEncoder().encode(body)
        
        let data = try await APIClient.request(
            urlString: "/task/complete-task",
            method: "POST",
            body: encodedBody
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponse.self, from: data)

        return response.status == "OK" ? true : false
    }
    
    static func deleteTask(task_id: Int) async throws -> Bool {
        let body = DeleteTaskRequest(user_id: AppState.shared.user_id, task_id: task_id)
        let encodedBody = try JSONEncoder().encode(body)
        
        let data = try await APIClient.request(
            urlString: "/task/delete-task",
            method: "DELETE",
            body: encodedBody
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponse.self, from: data)

        return response.status == "OK" ? true : false
    }
}

