import SwiftUI

struct SettlementCard: View {
    let settlement: SuggestedSettlement
    let currency: Currency
    let onRecord: () -> Void

    var body: some View {
        SplitCard(elevation: .medium) {
            HStack(spacing: 14) {
                VStack(spacing: 8) {
                    MemberAvatarView(name: settlement.fromMemberName, tone: .debt, size: 40)
                    Image(systemName: "arrow.down")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.splitMuted)
                    MemberAvatarView(name: settlement.toMemberName, tone: .credit, size: 40)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(settlement.fromMemberName) pays")
                        .font(.caption)
                        .foregroundColor(.splitMuted)
                    Text(settlement.toMemberName)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(formatCurrency(settlement.amount, currency: currency))
                        .font(.title2.weight(.bold))
                        .foregroundColor(.splitCredit)
                }

                Spacer()

                Button(action: onRecord) {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("Mark")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(SplitGradient.creditButton)
                            .shadow(color: Color.splitCredit.opacity(0.28), radius: 6, y: 3)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
