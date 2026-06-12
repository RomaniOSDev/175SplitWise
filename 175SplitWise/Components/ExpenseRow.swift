import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    let members: [Member]
    let paidByName: String?
    var baseCurrency: Currency?

    private var dateText: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: expense.date)
    }

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(systemName: expense.category.icon, color: .splitCredit, size: 50)

            VStack(alignment: .leading, spacing: 6) {
                Text(expense.title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    StatusBadge(text: expense.category.rawValue, tone: .neutral)
                    Text(dateText)
                        .font(.caption2)
                        .foregroundColor(.splitMuted)
                    if let baseCurrency, expense.currency != baseCurrency {
                        Text(expense.currency.rawValue)
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.splitCredit)
                    }
                }

                if let paidByName {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                        Text("Paid by \(paidByName)")
                            .font(.caption)
                    }
                    .foregroundColor(.splitMuted)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(expense.amount, currency: expense.currency))
                    .font(.headline.weight(.bold))
                    .foregroundColor(.splitCredit)
                Image(systemName: "pencil.circle.fill")
                    .font(.caption)
                    .foregroundColor(.splitMuted.opacity(0.4))
            }
        }
        .padding(14)
        .splitCardStyle(cornerRadius: 14, elevation: .low)
    }
}
