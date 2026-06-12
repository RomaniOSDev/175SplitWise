import SwiftUI

struct SettlementHistoryRow: View {
    let settlement: Settlement
    let fromName: String
    let toName: String
    let currency: Currency

    private var dateText: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: settlement.date)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(SplitGradient.creditSoft)
                    .frame(width: 44, height: 44)
                Image(systemName: "arrow.left.arrow.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.splitCredit)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(fromName).fontWeight(.semibold)
                    Image(systemName: "arrow.right").font(.caption2).foregroundColor(.splitMuted)
                    Text(toName).fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.black)

                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.splitMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(settlement.amount, currency: currency))
                    .font(.headline.weight(.bold))
                    .foregroundColor(.splitCredit)
                StatusBadge(text: "Done", tone: .credit, icon: "checkmark")
            }
        }
        .padding(14)
        .splitCardStyle(cornerRadius: 14, elevation: .low)
        .padding(.horizontal, 20)
    }
}
