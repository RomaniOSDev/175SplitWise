import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    @State private var filter = ExpenseFilter()
    @State private var allMembers: [Member] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statsHero

                ExpenseFilterBar(filter: $filter, members: allMembers)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(title: "Groups", value: "\(viewModel.groups.count)", icon: "person.3.fill", color: .splitCredit, compact: true)
                    StatCard(title: "Members", value: "\(viewModel.totalMembers)", icon: "person.fill", color: .splitCredit, compact: true)
                    StatCard(title: "Expenses", value: "\(filteredExpenseCount)", icon: "creditcard.fill", color: .splitCredit, compact: true)
                    StatCard(title: "Total", value: formatCurrency(filteredTotalAmount), icon: "rublesign.circle.fill", color: .splitCredit, compact: true)
                }
                .padding(.horizontal, 20)

                sectionCard(title: "Top groups by month", icon: "trophy.fill") {
                    let ranks = viewModel.topGroupsByMonth()
                    if ranks.isEmpty {
                        emptyLabel("No data yet")
                    } else {
                        ForEach(Array(ranks.enumerated()), id: \.element.id) { index, rank in
                            GroupComparisonRow(stat: rank, rank: index + 1)
                            if index < ranks.count - 1 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                }

                sectionCard(title: "Spending by member", icon: "person.2.fill") {
                    let stats = viewModel.memberStatsAllGroups(filter: filter)
                    if stats.isEmpty {
                        emptyLabel("No expenses yet")
                    } else {
                        ForEach(stats) { stat in
                            GlobalMemberStatCell(stat: stat)
                            if stat.id != stats.last?.id {
                                Divider().padding(.leading, 58)
                            }
                        }
                    }
                }

                sectionCard(title: "By category", icon: "chart.pie.fill") {
                    let stats = viewModel.expenseByCategory(filter: filter)
                    if stats.isEmpty {
                        emptyLabel("No expenses yet")
                    } else {
                        ForEach(stats) { stat in
                            CategoryStatCell(
                                name: stat.name,
                                icon: stat.icon,
                                amount: stat.amount,
                                percentage: stat.percentage
                            )
                        }
                    }
                }

                sectionCard(title: "Monthly activity", icon: "calendar") {
                    let data = viewModel.monthlyExpenses(filter: filter)
                    if data.isEmpty {
                        emptyLabel("No activity yet")
                    } else {
                        Chart {
                            ForEach(data) { item in
                                BarMark(
                                    x: .value("Month", item.month),
                                    y: .value("Amount", item.amount)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.splitCredit, .splitCredit.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(6)
                            }
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .splitScreenBackground()
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            allMembers = viewModel.groups.flatMap { $0.members }
        }
    }

    private var statsHero: some View {
        HStack(spacing: 16) {
            IconBadgeView(systemName: "chart.bar.xaxis", color: .splitCredit, size: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text("Insights")
                    .font(.headline)
                Text("Filtered analytics across all your groups")
                    .font(.caption)
                    .foregroundColor(.splitMuted)
            }
            Spacer()
        }
        .padding(16)
        .splitCardStyle(elevation: .medium)
        .padding(.horizontal, 20)
    }

    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.splitCredit)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            content()
        }
        .padding(16)
        .splitCardStyle(elevation: .medium)
        .padding(.horizontal, 20)
    }

    private func emptyLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.splitMuted)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 12)
    }

    private var filteredExpenseCount: Int {
        viewModel.groups.reduce(0) { $0 + viewModel.filteredExpenses(for: $1, filter: filter).count }
    }

    private var filteredTotalAmount: Double {
        viewModel.groups.reduce(0.0) { total, group in
            total + viewModel.filteredExpenses(for: group, filter: filter).reduce(0.0) {
                $0 + CurrencyConverter.toBase(amount: $1.amount, from: $1.currency, group: group)
            }
        }
    }
}
