//
//  AppState.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var baseURL: String = "http://localhost:3001/api"
}
