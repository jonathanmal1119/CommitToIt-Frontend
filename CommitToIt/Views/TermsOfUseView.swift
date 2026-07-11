//
//  TermsOfUseView.swift
//  CommitToIt
//

import SwiftUI

/// In-app Terms of Use, reachable from Settings. Not strictly required by
/// App Review for a free app with no subscriptions, but pairs with the
/// Privacy Policy and avoids relying on Apple's default EULA alone.
struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Use")
                        .font(.title.bold())

                    Text("Last updated: July 11, 2026")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    legalSection(
                        title: "Acceptance of Terms",
                        body: "By creating an account or using CommitToIt (\"the App\"), you agree to these Terms of Use. If you do not agree, please do not use the App."
                    )

                    legalSection(
                        title: "Your Account",
                        body: "You're responsible for maintaining the confidentiality of your login credentials and for all activity under your account. You must provide accurate information when creating an account."
                    )

                    legalSection(
                        title: "Acceptable Use",
                        body: "The App is provided for personal task-tracking and self-motivation. You agree not to misuse the App, attempt to disrupt its backend services, or use it for any unlawful purpose."
                    )

                    legalSection(
                        title: "Rewards & Points",
                        body: "Points earned within the App have no cash value and cannot be exchanged, transferred, or redeemed for real currency. Rewards are user-defined goals you set for yourself; the App does not fulfill, ship, or guarantee any physical or monetary reward."
                    )

                    legalSection(
                        title: "Termination & Account Deletion",
                        body: "You may delete your account at any time from Settings → Delete Account, which permanently removes your data from our servers. We may suspend or terminate accounts that violate these terms."
                    )

                    legalSection(
                        title: "Disclaimer",
                        body: "The App is provided \"as is\" without warranties of any kind. We aren't liable for any indirect or consequential damages arising from your use of the App."
                    )

                    legalSection(
                        title: "Changes to These Terms",
                        body: "We may update these terms from time to time. Continued use of the App after changes constitutes acceptance of the updated terms."
                    )

                    legalSection(
                        title: "Contact Us",
                        body: "Questions about these terms can be sent to jmaxmalave@gmail.com."
                    )
                }
                .padding(20)
            }
            .navigationTitle("Terms of Use")
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
    TermsOfUseView()
}
