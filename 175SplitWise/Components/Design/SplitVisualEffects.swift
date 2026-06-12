import SwiftUI

// MARK: - Elevation (single shadow per surface — GPU-friendly)

enum SplitElevation {
    case flat
    case low
    case medium
    case high
    case glow(Color)

    var radius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 4
        case .medium: return 8
        case .high: return 12
        case .glow: return 10
        }
    }

    var y: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 2
        case .medium: return 4
        case .high: return 6
        case .glow: return 4
        }
    }

    func shadowColor() -> Color {
        switch self {
        case .flat: return .clear
        case .low: return Color.splitShadow
        case .medium: return Color.black.opacity(0.09)
        case .high: return Color.black.opacity(0.11)
        case .glow(let c): return c.opacity(0.28)
        }
    }
}

// MARK: - View modifiers

extension View {
    /// App screen background with a light static gradient.
    func splitScreenBackground() -> some View {
        background {
            SplitGradient.screen
                .ignoresSafeArea()
        }
    }

    /// Standard elevated white card — one shadow, gradient border, clip.
    func splitCardStyle(
        cornerRadius: CGFloat = 16,
        elevation: SplitElevation = .medium,
        padding: CGFloat = 0
    ) -> some View {
        modifier(SplitCardModifier(cornerRadius: cornerRadius, elevation: elevation, padding: padding))
    }

    /// Inset surface for nested content (no shadow).
    func splitInsetSurface(cornerRadius: CGFloat = 12) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(SplitGradient.creditSoft.opacity(0.35))
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.splitCredit.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct SplitCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let elevation: SplitElevation
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white)
                    .shadow(
                        color: elevation.shadowColor(),
                        radius: elevation.radius,
                        x: 0,
                        y: elevation.y
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(SplitGradient.cardBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Reusable surfaces

struct SplitIconBadge: View {
    let systemName: String
    var color: Color = .splitCredit
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.22), color.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .splitCardStyle(cornerRadius: size * 0.28, elevation: .low, padding: 0)
    }
}
