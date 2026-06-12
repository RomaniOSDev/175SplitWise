import SwiftUI

struct GroupHeroHeader: View {
    let group: SplitGroup
    let balances: [Balance]

    private var isSettled: Bool {
        group.isSettled(balances: balances)
    }

    var body: some View {
        SplitCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    IconBadgeView(systemName: "person.3.fill", color: .splitCredit, size: 56)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(group.name)
                            .font(.title2.weight(.bold))
                            .foregroundColor(.black)
                        HStack(spacing: 8) {
                            StatusBadge(text: group.currency.rawValue, tone: .neutral, icon: "dollarsign.circle")
                            StatusBadge(
                                text: isSettled ? "All settled" : "Action needed",
                                tone: isSettled ? .credit : .debt,
                                icon: isSettled ? "checkmark.seal.fill" : "bell.fill"
                            )
                        }
                    }
                    Spacer()
                }

                HStack(spacing: 0) {
                    heroMetric(
                        title: "Spent",
                        value: formatCurrency(group.totalExpensesInBase, currency: group.currency),
                        color: .splitCredit
                    )
                    Divider().frame(height: 36)
                    heroMetric(
                        title: "Expenses",
                        value: "\(group.expenses.count)",
                        color: .black
                    )
                    Divider().frame(height: 36)
                    heroMetric(
                        title: "Members",
                        value: "\(group.members.count)",
                        color: .black
                    )
                }

                if let limit = group.budgetLimit {
                    BudgetProgressView(
                        spent: group.totalExpensesInBase,
                        limit: limit,
                        currency: group.currency,
                        embedded: true
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func heroMetric(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.splitMuted)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}
