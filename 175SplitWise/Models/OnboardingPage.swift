import Foundation

struct OnboardingPage: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let subtitle: String
    let icon: String

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "onboarding_1",
            title: "Create groups",
            subtitle: "Organize trips, dinners, and events with friends in one place.",
            icon: "person.3.fill"
        ),
        OnboardingPage(
            id: 1,
            imageName: "onboarding_2",
            title: "Track expenses",
            subtitle: "Add bills, split fairly, and support multiple currencies.",
            icon: "creditcard.fill"
        ),
        OnboardingPage(
            id: 2,
            imageName: "onboarding_3",
            title: "Settle up fast",
            subtitle: "See clear balances and record payments in a tap.",
            icon: "checkmark.circle.fill"
        )
    ]
}

enum OnboardingStorage {
    private static let key = "hasCompletedOnboarding"

    static var hasCompleted: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: key)
    }

    static func resetForPreview() {
        UserDefaults.standard.set(false, forKey: key)
    }
}
