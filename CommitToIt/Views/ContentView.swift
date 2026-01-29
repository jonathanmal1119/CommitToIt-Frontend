//
//  ContentView.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/25/26.
//

import SwiftUI

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var point_value: Int
    var icon: String
    var completed_at: Date?
}

struct Reward: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var cost: Int
    var icon: String
    var redeemed_at: Date?
}



struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
}
