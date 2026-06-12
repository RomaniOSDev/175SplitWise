import SwiftUI

struct BalanceRow: View {
    let balance: Balance
    let currency: Currency

    private var tone: AvatarTone {
        if balance.amount > 0.01 { return .credit }
        if balance.amount < -0.01 { return .debt }
        return .neutral
    }

    private var borderGradient: LinearGradient {
        balance.amount >= 0 ? SplitGradient.creditSoft : SplitGradient.debtSoft
    }

    var body: some View {
        HStack(spacing: 14) {
            MemberAvatarView(name: balance.memberName, tone: tone, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(balance.memberName)
                    .font(.headline)
                    .foregroundColor(.black)

                if balance.amount > 0.01 {
                    StatusBadge(text: "Is owed", tone: .credit, icon: "arrow.down.left")
                } else if balance.amount < -0.01 {
                    StatusBadge(text: "Owes", tone: .debt, icon: "arrow.up.right")
                } else {
                    StatusBadge(text: "Settled", tone: .neutral, icon: "equal")
                }
            }

            Spacer()

            if balance.amount > 0.01 {
                Text("+\(formatCurrency(balance.amount, currency: currency))")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.splitCredit)
            } else if balance.amount < -0.01 {
                Text(formatCurrency(abs(balance.amount), currency: currency))
                    .font(.title3.weight(.bold))
                    .foregroundColor(.splitDebt)
            } else {
                Text("0 \(currency.symbol)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.splitMuted)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.splitShadow, radius: 6, y: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(borderGradient, lineWidth: 1.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 20)
    }
}
