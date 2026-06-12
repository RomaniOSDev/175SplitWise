import SwiftUI

struct GroupCard: View {
    let group: SplitGroup
    let balances: [Balance]

    private var isSettled: Bool {
        group.isSettled(balances: balances)
    }

    private var outstandingDebt: Double {
        balances.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }

    var body: some View {
        HStack(spacing: 0) {
            AccentStripe(color: isSettled ? .splitCredit : .splitDebt)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    IconBadgeView(systemName: "person.3.fill", color: .splitCredit, size: 52)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(.headline)
                            .foregroundColor(.black)
                        HStack(spacing: 6) {
                            Label("\(group.members.count)", systemImage: "person.fill")
                            Text("•")
                            Label("\(group.expenses.count)", systemImage: "creditcard")
                        }
                        .font(.caption)
                        .foregroundColor(.splitMuted)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(group.currency.symbol)
                            .font(.caption.weight(.bold))
                            .foregroundColor(.splitCredit)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(SplitGradient.creditSoft)
                            .clipShape(Capsule())
                        CellChevron()
                    }
                }

                memberAvatarsRow

                if let limit = group.budgetLimit {
                    BudgetProgressView(
                        spent: group.totalExpensesInBase,
                        limit: limit,
                        currency: group.currency,
                        embedded: true
                    )
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total spent")
                            .font(.caption2)
                            .foregroundColor(.splitMuted)
                        Text(formatCurrency(group.totalExpensesInBase, currency: group.currency))
                            .font(.title3.weight(.bold))
                            .foregroundColor(.splitCredit)
                    }
                    Spacer()
                    if isSettled {
                        StatusBadge(text: "Settled", tone: .credit, icon: "checkmark.circle.fill")
                    } else {
                        VStack(alignment: .trailing, spacing: 4) {
                            StatusBadge(text: "Unsettled", tone: .debt, icon: "exclamationmark.circle.fill")
                            if outstandingDebt > 0 {
                                Text(formatCurrency(outstandingDebt, currency: group.currency))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(.splitDebt)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .splitCardStyle(elevation: .medium)
    }

    private var memberAvatarsRow: some View {
        HStack(spacing: -10) {
            ForEach(group.members.prefix(4)) { member in
                MemberAvatarView(name: member.name, tone: .neutral, size: 32)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            if group.members.count > 4 {
                ZStack {
                    Circle()
                        .fill(SplitGradient.creditSoft)
                        .frame(width: 32, height: 32)
                    Text("+\(group.members.count - 4)")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.splitMuted)
                }
            }
            Spacer()
        }
    }
}
