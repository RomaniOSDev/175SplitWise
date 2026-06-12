import SwiftUI

struct SettleView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    let group: SplitGroup
    @Environment(\.dismiss) private var dismiss

    private var suggestions: [SuggestedSettlement] {
        viewModel.suggestedSettlements(for: group)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    settleHero

                    if suggestions.isEmpty {
                        EmptyStateView(
                            icon: "party.popper.fill",
                            title: "All settled!",
                            message: "No transfers needed — every balance in this group is clear."
                        )
                    } else {
                        SectionHeaderView(
                            title: "Suggested transfers",
                            subtitle: "\(suggestions.count) payment\(suggestions.count == 1 ? "" : "s")"
                        )

                        ForEach(suggestions) { settlement in
                            SettlementCard(
                                settlement: settlement,
                                currency: group.currency
                            ) {
                                withAnimation {
                                    viewModel.recordSettlement(for: group.id, suggestion: settlement)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .splitScreenBackground()
            .navigationTitle("Settle Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .font(.body.weight(.semibold))
                        .foregroundColor(.splitCredit)
                }
            }
        }
    }

    private var settleHero: some View {
        SplitCard {
            HStack(spacing: 14) {
                IconBadgeView(systemName: "arrow.left.arrow.right.circle.fill", color: .splitCredit, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Minimize transfers")
                        .font(.headline)
                    Text("Tap Mark when a payment is completed")
                        .font(.caption)
                        .foregroundColor(.splitMuted)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
