import SwiftUI

extension Color {
    static let splitBackground = Color(red: 0.996, green: 1.0, blue: 1.0)
    static let splitBackgroundSoft = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let splitDebt = Color(red: 0.831, green: 0.0, blue: 0.149)
    static let splitCredit = Color(red: 0.0, green: 0.373, blue: 1.0)
    static let splitMuted = Color(red: 0.45, green: 0.48, blue: 0.52)
    static let splitBorder = Color.black.opacity(0.06)
    static let splitShadow = Color.black.opacity(0.07)
}

// MARK: - Static gradients (reused, no per-frame allocation)

enum SplitGradient {
    static let screen = LinearGradient(
        colors: [
            Color.splitBackground,
            Color.splitCredit.opacity(0.05),
            Color.splitBackgroundSoft
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let creditButton = LinearGradient(
        colors: [Color.splitCredit, Color(red: 0.0, green: 0.30, blue: 0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let creditSoft = LinearGradient(
        colors: [Color.splitCredit.opacity(0.14), Color.splitCredit.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let debtSoft = LinearGradient(
        colors: [Color.splitDebt.opacity(0.12), Color.splitDebt.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardShine = LinearGradient(
        colors: [Color.white.opacity(0.95), Color.white.opacity(0.75)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardBorder = LinearGradient(
        colors: [Color.white.opacity(0.9), Color.splitBorder],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroOverlay = LinearGradient(
        colors: [Color.clear, Color.black.opacity(0.55)],
        startPoint: .center,
        endPoint: .bottom
    )
}
