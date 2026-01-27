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
}

struct ContentView: View {
    var body: some View {
        //MainTabView()
    }
}

#Preview {
    ContentView()
}
