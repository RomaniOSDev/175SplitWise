import SwiftUI

struct RecentActivityCell: View {
    let expense: Expense
    let groupName: String
    let paidByName: String?

    private var dateText: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: expense.date, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            IconBadgeView(systemName: expense.category.icon, color: .splitCredit, size: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(groupName)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.splitCredit)
                    Text("•").foregroundColor(.splitMuted)
                    Text(dateText)
                        .font(.caption2)
                        .foregroundColor(.splitMuted)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(expense.amount, currency: expense.currency))
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.splitCredit)
                if let paidByName {
                    Text(paidByName)
                        .font(.caption2)
                        .foregroundColor(.splitMuted)
                }
            }
        }
        .padding(12)
        .splitCardStyle(cornerRadius: 12, elevation: .low)
    }
}
