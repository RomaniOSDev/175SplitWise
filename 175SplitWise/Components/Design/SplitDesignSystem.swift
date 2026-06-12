import SwiftUI

// MARK: - Card container

struct SplitCard<Content: View>: View {
    var padding: CGFloat = 16
    var elevation: SplitElevation = .medium
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .splitCardStyle(elevation: elevation)
    }
}

// MARK: - Section header

struct SectionHeaderView: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(0.8)
                    .foregroundColor(.splitMuted)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.splitMuted.opacity(0.8))
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.splitCredit)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Avatar

enum AvatarTone {
    case credit, debt, neutral

    var gradient: LinearGradient {
        switch self {
        case .credit:
            return LinearGradient(
                colors: [Color.splitCredit.opacity(0.2), Color.splitCredit.opacity(0.08)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .debt:
            return LinearGradient(
                colors: [Color.splitDebt.opacity(0.2), Color.splitDebt.opacity(0.08)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .neutral:
            return LinearGradient(
                colors: [Color.gray.opacity(0.16), Color.gray.opacity(0.06)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var foreground: Color {
        switch self {
        case .credit: return .splitCredit
        case .debt: return .splitDebt
        case .neutral: return .splitMuted
        }
    }
}

struct MemberAvatarView: View {
    let name: String
    var tone: AvatarTone = .neutral
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(tone.gradient)
            Text(name.prefix(1).uppercased())
                .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                .foregroundColor(tone.foreground)
        }
        .frame(width: size, height: size)
        .overlay {
            Circle()
                .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
        }
    }
}

// MARK: - Icon badge (uses shared lightweight style)

struct IconBadgeView: View {
    let systemName: String
    var color: Color = .splitCredit
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.2), color.opacity(0.07)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Status badge

enum BadgeTone {
    case credit, debt, neutral

    var gradient: LinearGradient {
        switch self {
        case .credit: return SplitGradient.creditSoft
        case .debt: return SplitGradient.debtSoft
        case .neutral:
            return LinearGradient(
                colors: [Color.gray.opacity(0.14), Color.gray.opacity(0.06)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var foreground: Color {
        switch self {
        case .credit: return .splitCredit
        case .debt: return .splitDebt
        case .neutral: return .splitMuted
        }
    }
}

struct StatusBadge: View {
    let text: String
    var tone: BadgeTone = .neutral
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
            }
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(tone.foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(tone.gradient)
        .clipShape(Capsule())
        .overlay {
            Capsule().strokeBorder(tone.foreground.opacity(0.15), lineWidth: 0.5)
        }
    }
}

// MARK: - Buttons

struct SplitPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundColor(.white)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isEnabled ? AnyShapeStyle(SplitGradient.creditButton) : AnyShapeStyle(Color.gray.opacity(0.4)))
                    .shadow(
                        color: isEnabled ? Color.splitCredit.opacity(0.3) : .clear,
                        radius: 8,
                        y: 4
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(!isEnabled)
    }
}

struct SplitSecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundColor(.splitCredit)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(SplitGradient.creditSoft)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.splitCredit.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            IconBadgeView(systemName: icon, color: .splitCredit, size: 64)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.splitMuted)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                SplitPrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .splitCardStyle(elevation: .low)
    }
}

// MARK: - Form styling

struct SplitFormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(0.6)
                .foregroundColor(.splitMuted)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .splitCardStyle(cornerRadius: 14, elevation: .low)
        }
    }
}

struct SplitFormRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }
}

// MARK: - Cell chrome

struct CellChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundColor(.splitMuted.opacity(0.5))
    }
}

struct AccentStripe: View {
    var color: Color = .splitCredit

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 4)
            .shadow(color: color.opacity(0.35), radius: 2, y: 0)
    }
}
