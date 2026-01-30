//
//  Project.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/29/26.
//
import Foundation

struct Project: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    var title: String
    var icon: String
}
