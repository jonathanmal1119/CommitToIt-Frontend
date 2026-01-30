//
//  Task.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//

import Foundation

struct Task: Identifiable, Codable, Equatable {
    var id: Int
    var title: String
    var point_value: Int
    var icon: String
    var completed_at: Date?
    var project_id: Int?
    var project_name: String?
}
