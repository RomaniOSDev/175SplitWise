import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var viewModel: SplitWiseViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                settingsHero

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "General")

                    NavigationLink {
                        TemplatesManageView(viewModel: viewModel)
                    } label: {
                        settingsNavigationRow(
                            title: "Expense Templates",
                            icon: "doc.on.doc.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Support")

                    SettingsRowCell(
                        title: "Rate Us",
                        icon: "star.fill",
                        iconColor: .orange
                    ) {
                        rateApp()
                    }

                    SettingsRowCell(
                        title: AppLink.privacyPolicy.title,
                        icon: AppLink.privacyPolicy.icon
                    ) {
                        openLink(.privacyPolicy)
                    }

                    SettingsRowCell(
                        title: AppLink.termsOfUse.title,
                        icon: AppLink.termsOfUse.icon
                    ) {
                        openLink(.termsOfUse)
                    }
                }

                appInfoFooter
            }
            .padding(.vertical, 12)
        }
        .splitScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    private var settingsHero: some View {
        HStack(spacing: 16) {
            IconBadgeView(systemName: "gearshape.fill", color: .splitCredit, size: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text("Preferences")
                    .font(.headline)
                    .foregroundColor(.black)
                Text("Templates, feedback, and legal information")
                    .font(.caption)
                    .foregroundColor(.splitMuted)
            }
            Spacer()
        }
        .padding(16)
        .splitCardStyle(elevation: .medium)
        .padding(.horizontal, 20)
    }

    private func settingsNavigationRow(title: String, icon: String) -> some View {
        HStack(spacing: 14) {
            IconBadgeView(systemName: icon, color: .splitCredit, size: 44)
            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(.black)
            Spacer()
            CellChevron()
        }
        .padding(14)
        .splitCardStyle(cornerRadius: 14, elevation: .low)
        .padding(.horizontal, 20)
    }

    private var appInfoFooter: some View {
        VStack(spacing: 4) {
            Text("Version \(appVersion)")
                .font(.caption)
                .foregroundColor(.splitMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func openLink(_ link: AppLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
