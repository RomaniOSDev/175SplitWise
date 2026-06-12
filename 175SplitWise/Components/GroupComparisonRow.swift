import SwiftUI

struct GroupComparisonRow: View {
    let stat: SplitWiseViewModel.GroupMonthlyRank
    var rank: Int = 0

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                if rank > 0 {
                    Text("\(rank)")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(rankColor)
                } else {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                        .foregroundColor(.splitCredit)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(stat.groupName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                Text(stat.monthLabel)
                    .font(.caption)
                    .foregroundColor(.splitMuted)
            }

            Spacer()

            Text(formatCurrency(stat.amount, currency: stat.currency))
                .font(.subheadline.weight(.bold))
                .foregroundColor(.splitCredit)
        }
        .padding(.vertical, 8)
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .splitCredit
        case 2: return Color.orange
        case 3: return Color.purple.opacity(0.8)
        default: return .splitMuted
        }
    }
}

struct CategoryStatCell: View {
    let name: String
    let icon: String
    let amount: Double
    let percentage: Double

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(systemName: icon, color: .splitCredit, size: 40)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Text(formatCurrency(amount))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.splitCredit)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.12))
                        Capsule()
                            .fill(SplitGradient.creditButton)
                            .frame(width: max(geo.size.width * percentage / 100, 4))
                    }
                }
                .frame(height: 8)

                Text("\(Int(percentage))% of total")
                    .font(.caption2)
                    .foregroundColor(.splitMuted)
            }
        }
        .padding(.vertical, 6)
    }
}

struct GlobalMemberStatCell: View {
    let stat: SplitWiseViewModel.MemberExpenseStat

    var body: some View {
        HStack(spacing: 14) {
            MemberAvatarView(
                name: stat.memberName,
                tone: stat.netContribution >= 0 ? .credit : .debt,
                size: 44
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(stat.memberName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)

                HStack(spacing: 12) {
                    Label(formatCurrency(stat.totalPaid), systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundColor(.splitCredit)
                    Label(formatCurrency(stat.totalShare), systemImage: "cart.fill")
                        .font(.caption)
                        .foregroundColor(.splitMuted)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
