//
//  PrivacyPolicyView.swift
//  CommitToIt
//

import SwiftUI

/// In-app privacy policy. App Store Review Guideline 5.1.1 requires the
/// policy to be reachable both from the App Store listing and from within
/// the app itself, so this is rendered locally rather than linking out.
///
/// Keep this in sync with `PrivacyInfo.xcprivacy` — the data types listed
/// below should always match what that manifest declares.
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title.bold())

                    Text("Last updated: July 11, 2026")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    legalSection(
                        title: "Overview",
                        body: "CommitToIt (\"the App\") is a task-tracking and rewards app. This policy explains what information we collect, why we collect it, and how it's used."
                    )

                    legalSection(
                        title: "Information We Collect",
                        body: "When you create an account, we collect your username, email address, and password. We do not store your password in plain text. As you use the App, we store the tasks and rewards you create, your task completion history, and your point balance, all associated with your account (a system-generated user ID)."
                    )

                    legalSection(
                        title: "How We Use Your Information",
                        body: "We use this information solely to operate the App's core functionality: authenticating you, syncing your tasks and rewards across sessions, and calculating your points and progress. We do not sell your data, and we do not use it for advertising or cross-app tracking."
                    )

                    legalSection(
                        title: "Notifications",
                        body: "If you enable notifications, the App schedules local reminders on your device for upcoming task due dates. These reminders are generated and delivered entirely on-device and are not sent through a third-party push notification or analytics service."
                    )

                    legalSection(
                        title: "Data Storage & Security",
                        body: "Your account data is stored on our servers over an encrypted (HTTPS) connection. Authentication tokens are stored securely in your device's Keychain and are never accessible to other apps."
                    )

                    legalSection(
                        title: "Data Sharing",
                        body: "We do not share your personal information with third parties, except as required to operate the App's backend infrastructure (e.g., hosting providers) or where required by law."
                    )

                    legalSection(
                        title: "Data Retention & Deletion",
                        body: "You can permanently delete your account and all associated data at any time from Settings → Delete Account. This action is irreversible and removes your tasks, rewards, and profile information from our servers."
                    )

                    legalSection(
                        title: "Children's Privacy",
                        body: "The App is not directed at children under 13, and we do not knowingly collect personal information from children under 13."
                    )

                    legalSection(
                        title: "Changes to This Policy",
                        body: "We may update this policy from time to time. Material changes will be reflected in the \"Last updated\" date above."
                    )

                    legalSection(
                        title: "Contact Us",
                        body: "If you have questions about this policy or your data, contact us at jmaxmalave@gmail.com."
                    )
                }
                .padding(20)
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    private func legalSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.body)
                .foregroundColor(.primary.opacity(0.85))
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
