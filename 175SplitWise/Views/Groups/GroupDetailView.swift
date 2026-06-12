import SwiftUI

struct GroupDetailView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    let groupId: UUID

    @State private var expenseFilter = ExpenseFilter()
    @State private var showAddExpenseSheet = false
    @State private var showSettleSheet = false
    @State private var showEditGroupSheet = false
    @State private var expenseToEdit: Expense?
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var expandedSections: Set<DetailSection> = [.balances, .expenses]

    private enum DetailSection: String, CaseIterable, Hashable {
        case balances, members, settlements, expenses
    }

    private var group: SplitGroup? {
        viewModel.group(with: groupId)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let group {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            GroupHeroHeader(
                                group: group,
                                balances: viewModel.calculateBalances(for: group)
                            )

                            collapsibleSection(.balances) {
                                balancesContent(for: group)
                            }

                            collapsibleSection(.members) {
                                membersContent(for: group)
                            }

                            if !viewModel.completedSettlements(for: group).isEmpty {
                                collapsibleSection(.settlements) {
                                    settlementsContent(for: group)
                                }
                            }

                            collapsibleSection(.expenses) {
                                expensesContent(for: group)
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    EmptyStateView(
                        icon: "exclamationmark.triangle",
                        title: "Group not found",
                        message: "This group may have been deleted."
                    )
                }
            }

            if group != nil {
                bottomActionBar
            }
        }
        .splitScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(group?.name ?? "Group")
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showEditGroupSheet = true } label: {
                        Label("Edit Group", systemImage: "pencil")
                    }
                    Button { exportReport() } label: {
                        Label("Export Report", systemImage: "square.and.arrow.up")
                    }
                    Button { showSettleSheet = true } label: {
                        Label("Settle Up", systemImage: "arrow.left.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.splitCredit, Color.splitCredit.opacity(0.3))
                }
            }
        }
        .sheet(isPresented: $showAddExpenseSheet) {
            if let group {
                ExpenseFormView(viewModel: viewModel, group: group, mode: .add())
            }
        }
        .sheet(item: $expenseToEdit) { expense in
            if let group {
                ExpenseFormView(viewModel: viewModel, group: group, mode: .edit(expense))
            }
        }
        .sheet(isPresented: $showSettleSheet) {
            if let group {
                SettleView(viewModel: viewModel, group: group)
            }
        }
        .sheet(isPresented: $showEditGroupSheet) {
            if let group {
                GroupFormView(viewModel: viewModel, mode: .edit(group))
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                SplitPrimaryButton(title: "Add Expense", icon: "plus") {
                    showAddExpenseSheet = true
                }
                SplitSecondaryButton(title: "Settle", icon: "checkmark") {
                    showSettleSheet = true
                }
                .frame(width: 110)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                Color.white
                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: -4)
            }
        }
    }

    @ViewBuilder
    private func collapsibleSection<Content: View>(
        _ section: DetailSection,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    if expandedSections.contains(section) {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack {
                    SectionHeaderView(title: sectionTitle(section))
                    Spacer()
                    Image(systemName: expandedSections.contains(section) ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.splitMuted)
                        .padding(.trailing, 20)
                }
            }
            .buttonStyle(.plain)

            if expandedSections.contains(section) {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func sectionTitle(_ section: DetailSection) -> String {
        switch section {
        case .balances: return "Balances"
        case .members: return "Member Activity"
        case .settlements: return "Settlement History"
        case .expenses: return "Expenses"
        }
    }

    @ViewBuilder
    private func balancesContent(for group: SplitGroup) -> some View {
        let balances = viewModel.balances(for: group)
        if balances.isEmpty {
            EmptyStateView(
                icon: "checkmark.seal.fill",
                title: "All settled",
                message: "Everyone is even in this group."
            )
        } else {
            ForEach(balances) { balance in
                BalanceRow(balance: balance, currency: group.currency)
            }
        }
    }

    @ViewBuilder
    private func membersContent(for group: SplitGroup) -> some View {
        ForEach(viewModel.memberStats(for: group)) { stat in
            MemberStatRow(stat: stat, currency: group.currency)
        }
    }

    @ViewBuilder
    private func settlementsContent(for group: SplitGroup) -> some View {
        ForEach(viewModel.completedSettlements(for: group)) { settlement in
            SettlementHistoryRow(
                settlement: settlement,
                fromName: viewModel.memberName(for: settlement.fromMemberId, in: group) ?? "?",
                toName: viewModel.memberName(for: settlement.toMemberId, in: group) ?? "?",
                currency: group.currency
            )
        }
    }

    @ViewBuilder
    private func expensesContent(for group: SplitGroup) -> some View {
        ExpenseFilterBar(filter: $expenseFilter, members: group.members)

        let expenses = viewModel.recentExpenses(for: group, filter: expenseFilter)
        if expenses.isEmpty {
            EmptyStateView(
                icon: "creditcard",
                title: expenseFilter.isActive ? "No matches" : "No expenses",
                message: expenseFilter.isActive
                    ? "Try adjusting your filters."
                    : "Tap Add Expense to record the first one.",
                actionTitle: expenseFilter.isActive ? nil : "Add Expense",
                action: expenseFilter.isActive ? nil : { showAddExpenseSheet = true }
            )
        } else {
            LazyVStack(spacing: 10) {
                ForEach(expenses) { expense in
                    ExpenseRow(
                        expense: expense,
                        members: group.members,
                        paidByName: viewModel.memberName(for: expense.paidBy, in: group),
                        baseCurrency: group.currency
                    )
                    .padding(.horizontal, 20)
                    .onTapGesture { expenseToEdit = expense }
                    .contextMenu {
                        Button { expenseToEdit = expense } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            viewModel.deleteExpense(from: groupId, expense: expense)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private func exportReport() {
        guard let group else { return }
        var items: [Any] = [viewModel.exportText(for: group)]
        if let pdfURL = ExportReportBuilder.pdfFileURL(for: group, viewModel: viewModel) {
            items.append(pdfURL)
        }
        shareItems = items
        showShareSheet = true
    }
}
