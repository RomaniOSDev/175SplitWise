import SwiftUI

struct MemberStatRow: View {
    let stat: SplitWiseViewModel.MemberExpenseStat
    let currency: Currency

    private var shareProgress: Double {
        let maxShare = max(stat.totalShare, stat.totalPaid, 1)
        return min(stat.totalShare / maxShare, 1)
    }

    var body: some View {
        HStack(spacing: 14) {
            MemberAvatarView(
                name: stat.memberName,
                tone: stat.netContribution >= 0 ? .credit : .debt,
                size: 44
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(stat.memberName)
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    if stat.netContribution > 0.01 {
                        StatusBadge(text: "Lender", tone: .credit)
                    } else if stat.netContribution < -0.01 {
                        StatusBadge(text: "Consumer", tone: .debt)
                    }
                }

                HStack(spacing: 16) {
                    statColumn(title: "Paid", amount: stat.totalPaid, color: .splitCredit)
                    statColumn(title: "Share", amount: stat.totalShare, color: .black)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.12))
                        Capsule()
                            .fill(SplitGradient.creditButton)
                            .frame(width: max(geo.size.width * shareProgress, 4))
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(14)
        .splitCardStyle(cornerRadius: 14, elevation: .low)
        .padding(.horizontal, 20)
    }

    private func statColumn(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.splitMuted)
            Text(formatCurrency(amount, currency: currency))
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
        }
    }
}
