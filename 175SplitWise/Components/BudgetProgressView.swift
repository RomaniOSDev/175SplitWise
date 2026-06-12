import SwiftUI

struct BudgetProgressView: View {
    let spent: Double
    let limit: Double
    let currency: Currency
    var embedded: Bool = false

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }

    private var isOverBudget: Bool { spent > limit }

    private var progressColor: Color {
        if isOverBudget { return .splitDebt }
        if progress > 0.85 { return .orange }
        return .splitCredit
    }

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [progressColor, progressColor.opacity(0.65)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.pie.fill")
                        .font(.caption)
                        .foregroundColor(progressColor)
                    Text("Budget")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.splitMuted)
                }
                Spacer()
                Text("\(formatCurrency(spent, currency: currency)) / \(formatCurrency(limit, currency: currency))")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(isOverBudget ? .splitDebt : .splitCredit)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.12))
                    Capsule()
                        .fill(progressGradient)
                        .frame(width: max(geo.size.width * progress, 4))
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(Int(progress * 100))% used")
                    .font(.caption2)
                    .foregroundColor(.splitMuted)
                Spacer()
                if isOverBudget {
                    Text("Over by \(formatCurrency(spent - limit, currency: currency))")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.splitDebt)
                }
            }
        }
        .padding(embedded ? 0 : 16)
        .modifier(EmbeddedCardModifier(embedded: embedded))
    }
}

private struct EmbeddedCardModifier: ViewModifier {
    let embedded: Bool

    func body(content: Content) -> some View {
        if embedded {
            content
        } else {
            content.splitCardStyle(elevation: .low)
                .padding(.horizontal, 20)
        }
    }
}
