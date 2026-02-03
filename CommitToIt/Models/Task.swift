//
//  TaskItem.swift
//  APiTester
//
//  Created by Jonathan Malave on 2/2/26.
//

import Foundation

struct TaskResponse: Decodable {
    let status: String
    let message: String
    let data: TaskData
}

struct TaskData: Decodable {
    let inQueueTasks: [TaskItem]
    let pendingTasks: [TaskItem]
    let completedTasks: [TaskItem]
}

struct TaskItem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let point_value: Int
    let completed_at: Date?
    let filter: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "task_id"
        case title
        case description
        case point_value
        case completed_at
        case filter
    }
}


