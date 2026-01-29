//
//  DataManager.swift
//  CommitToIt
//
//  Created by Jonathan Malave on 1/27/26.
//

import SwiftUI
import Combine

class DataManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var rewards: [Reward] = []
    @Published var rewardsError: String? = nil
    
    func loadRedeemableRewards(appState: AppState) {
        self.rewardsError = nil
        APIService.shared.getRewards(baseURL: appState.baseURL) { result in
        DispatchQueue.main.async {
                switch result {
                     case .success(let rewards):
                        self.rewards = rewards
                        self.rewardsError = nil
                    case .failure(let error):
                        self.rewardsError = error.localizedDescription
                }
            }
        }
    }
}

