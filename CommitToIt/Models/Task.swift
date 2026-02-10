//
//  TaskItem.swift
//  APiTester
//
//  Created by Jonathan Malave on 2/2/26.
//

import Foundation


// Requests
struct AddTaskRequest: Encodable {
    let user_id: Int
    let title: String
    let description: String?
    let point_value: Int
}

struct UpdateTaskRequest {
    let user_id: Int
    let task_id: Int
    let title: String?
    let description: String?
}

struct MarkTaskCompletedRequest: Encodable {
    let user_id: Int
    let task_id: Int
}

struct DeleteTaskRequest: Encodable {
    let user_id: Int
    let task_id: Int
}


// Responses
struct TaskResponse: Decodable {
    let status: String
    let message: String
    let data: [TaskItem]?
}

struct TaskItem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let point_value: Int
    var completed_at: Date?
    let filter: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "task_id"
        case title = "title"
        case description = "description"
        case point_value = "point_value"
        case completed_at = "completed_at"
        case filter = "filter"
    }
}
