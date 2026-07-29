//
//  AdminUserLookupView.swift
//  CommitToIt
//

import SwiftUI

struct AdminUserLookupView: View {
    @State private var username = ""
    @State private var lookupResult: AdminUserLookupData?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Look Up") {
                        lookUpUser()
                    }
                    .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }

                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Looking up user…")
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }

            if let lookupResult {
                Section("User") {
                    LabeledContent("User ID", value: String(lookupResult.user_id))
                    LabeledContent("Username", value: lookupResult.username)
                    LabeledContent("Email", value: lookupResult.email)
                }

                Section("Stats") {
                    LabeledContent("Point Balance", value: String(lookupResult.stats.point_balance))
                    LabeledContent("Completed Tasks", value: String(lookupResult.stats.completed_tasks))
                    LabeledContent("Redeemed Rewards", value: String(lookupResult.stats.redeemed_rewards))
                    LabeledContent("Total Points Earned", value: String(lookupResult.stats.total_points_earned))
                }

                Section("Unredeemed Rewards") {
                    if lookupResult.unredeemed_rewards.isEmpty {
                        Text("No unredeemed rewards")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(lookupResult.unredeemed_rewards) { reward in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: reward.icon)
                                        .foregroundColor(.accent)
                                    Text(reward.title)
                                        .font(.headline)
                                }

                                Text(reward.description)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    Text("\(reward.cost) pts")
                                    if let earnedAt = reward.earned_at {
                                        Text("Purchased \(earnedAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("User Lookup")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func lookUpUser() {
        isLoading = true
        errorMessage = nil
        lookupResult = nil

        Task {
            do {
                let result = try await UserService.lookupUserByUsername(
                    username: username.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                lookupResult = result
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Couldn't find that user. Check the username and try again."
                print("[AdminUserLookup] \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdminUserLookupView()
    }
}
