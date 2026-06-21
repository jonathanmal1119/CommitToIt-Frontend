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
    
    static func createTask(title: String, description: String?, point_value: Int, due_date: Date?) async throws -> [TaskItem] {
        
        let body = AddTaskRequest(user_id: AppState.shared.user_id, title: title, description: description, point_value: point_value, due_date: due_date)
        
        let encoder = JSONEncoder()
        
        // MySQL datetime format: "YYYY-MM-DD HH:MM:SS"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let encodedBody = try encoder.encode(body)
        
        
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
    
    static func fetchCompletedUserTasks() async throws -> [TaskItem] {
        let data = try await APIClient.request(
            urlString: "/task?user_id=\(AppState.shared.user_id)&filter=completed",
            method: "GET"
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponse.self, from: data)
        
        return response.data ?? []
    }
    
    static func updateTaskInfo(title: String, description: String, due_date: Date, task_id: Int) async throws -> [TaskItem] {
        let body = DeleteTaskRequest(user_id: AppState.shared.user_id, task_id: task_id, )
        let encodedBody = try JSONEncoder().encode(body)
        
        let data = try await APIClient.request(
            urlString: "/task/update-task",
            method: "POST"
        )

        let decoder = Foundation.JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TaskResponse.self, from: data)
        
        return response.data ?? []
    }
}

