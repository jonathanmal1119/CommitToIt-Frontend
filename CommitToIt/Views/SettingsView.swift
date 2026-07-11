//
//  SettingsView.swift
//  CommitToIt
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var deleteErrorMessage: String?
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfUse = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent("Username", value: appState.user_info.username)
                    LabeledContent("Email", value: appState.user_info.email)
                }

                Section("Legal") {
                    Button("Privacy Policy") {
                        showPrivacyPolicy = true
                    }
                    .foregroundColor(.primary)

                    Button("Terms of Use") {
                        showTermsOfUse = true
                    }
                    .foregroundColor(.primary)
                }

                Section {
                    Button("Sign Out") {
                        showSignOutConfirm = true
                    }
                    .foregroundColor(.primary)
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        if isDeleting {
                            HStack {
                                ProgressView()
                                Text("Deleting Account…")
                            }
                        } else {
                            Text("Delete Account")
                        }
                    }
                    .disabled(isDeleting)

                    if let deleteErrorMessage {
                        Text(deleteErrorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                } footer: {
                    Text("Permanently deletes your account, tasks, and rewards. This cannot be undone.")
                }

                Section {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Sign out of CommitToIt?",
                isPresented: $showSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    AuthService.logout()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert(
                "Delete your account?",
                isPresented: $showDeleteConfirm
            ) {
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your account and all of your tasks and rewards. This cannot be undone.")
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showTermsOfUse) {
                TermsOfUseView()
            }
        }
    }

    private func deleteAccount() {
        isDeleting = true
        deleteErrorMessage = nil

        Task {
            do {
                try await AuthService.deleteAccount()
                isDeleting = false
            } catch {
                isDeleting = false
                deleteErrorMessage = "Couldn't delete account. Please try again later."
                print("[DeleteAccount] Error: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState(load_mock_data: true))
}
