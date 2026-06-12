import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    @Binding var selectedTab: Int

    @State private var showCreateGroup = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    private var recentActivity: [(expense: Expense, group: SplitGroup)] {
        viewModel.groups
            .flatMap { group in group.expenses.map { (expense: $0, group: group) } }
            .sorted { $0.expense.date > $1.expense.date }
            .prefix(5)
            .map { $0 }
    }

    private var unsettledGroups: [SplitGroup] {
        viewModel.groups.filter { group in
            !group.isSettled(balances: viewModel.calculateBalances(for: group))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroBanner
                statsGrid
                widgetsSection
                quickActions
                recentActivitySection
                attentionSection
                Spacer(minLength: 24)
            }
            .padding(.bottom, 16)
        }
        .splitScreenBackground()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCreateGroup) {
            GroupFormView(viewModel: viewModel, mode: .create)
        }
    }

    // MARK: - Hero

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_hero_banner")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()

            SplitGradient.heroOverlay

            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                Text(heroSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                HStack(spacing: 8) {
                    heroChip(
                        icon: "person.3.fill",
                        text: "\(viewModel.groups.count) groups"
                    )
                    heroChip(
                        icon: viewModel.totalDebt > 0 ? "exclamationmark.circle.fill" : "checkmark.circle.fill",
                        text: viewModel.totalDebt > 0 ? "Action needed" : "All clear"
                    )
                }
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.splitCredit.opacity(0.22), radius: 12, y: 6)
        .padding(.horizontal, 20)
    }

    private var heroSubtitle: String {
        if viewModel.groups.isEmpty {
            return "Create a group and start splitting expenses fairly."
        }
        if viewModel.totalDebt > 0 {
            return "You have \(formatCurrency(viewModel.totalDebt)) pending across groups."
        }
        return "Everything looks balanced. Great job!"
    }

    private func heroChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
    }

    // MARK: - Stats

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Total Spent",
                value: formatCurrency(viewModel.totalAmount),
                icon: "creditcard.fill",
                color: .splitCredit,
                compact: true
            )
            StatCard(
                title: "Outstanding",
                value: formatCurrency(viewModel.totalDebt),
                icon: "exclamationmark.circle.fill",
                color: .splitDebt,
                compact: true
            )
            StatCard(
                title: "Expenses",
                value: "\(viewModel.totalExpenses)",
                icon: "list.bullet.rectangle",
                color: .splitCredit,
                compact: true
            )
            StatCard(
                title: "Members",
                value: "\(viewModel.totalMembers)",
                icon: "person.fill",
                color: .splitCredit,
                compact: true
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Widgets

    private var widgetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Widgets", subtitle: "Tap to explore")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HomeWidgetCard(
                        title: "GROUPS",
                        value: "\(viewModel.groups.count)",
                        subtitle: "Active trips & events",
                        imageName: "home_widget_groups",
                        accentColor: .splitCredit
                    ) {
                        selectedTab = 1
                    }
                    .frame(width: 160)

                    HomeWidgetCard(
                        title: "EXPENSES",
                        value: "\(viewModel.totalExpenses)",
                        subtitle: "Recorded items",
                        imageName: "home_widget_expenses",
                        accentColor: .splitCredit
                    ) {
                        selectedTab = 1
                    }
                    .frame(width: 160)

                    HomeWidgetCard(
                        title: "TO SETTLE",
                        value: formatCurrency(viewModel.totalDebt),
                        subtitle: unsettledGroups.isEmpty ? "All balanced" : "\(unsettledGroups.count) groups open",
                        imageName: "home_widget_settle",
                        accentColor: viewModel.totalDebt > 0 ? .splitDebt : .splitCredit
                    ) {
                        selectedTab = 1
                    }
                    .frame(width: 160)
                }
                .padding(.horizontal, 20)
            }

            HomeWideWidget(
                title: "INSIGHTS",
                message: "View charts, categories, and monthly trends",
                value: formatCurrency(viewModel.totalSettled),
                imageName: "home_widget_expenses",
                accentColor: .splitCredit
            ) {
                selectedTab = 2
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions")

            HStack(spacing: 12) {
                quickActionButton(
                    title: "New Group",
                    icon: "plus.circle.fill",
                    color: .splitCredit
                ) {
                    showCreateGroup = true
                }

                quickActionButton(
                    title: "All Groups",
                    icon: "person.3.fill",
                    color: .splitCredit
                ) {
                    selectedTab = 1
                }

                quickActionButton(
                    title: "Statistics",
                    icon: "chart.bar.fill",
                    color: .splitCredit
                ) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func quickActionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .splitCardStyle(cornerRadius: 14, elevation: .low)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent activity

    @ViewBuilder
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Recent Activity",
                actionTitle: recentActivity.isEmpty ? nil : "See all",
                action: recentActivity.isEmpty ? nil : { selectedTab = 1 }
            )

            if recentActivity.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No activity yet",
                    message: "Your latest expenses will appear here.",
                    actionTitle: "Create Group",
                    action: { showCreateGroup = true }
                )
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(recentActivity, id: \.expense.id) { item in
                        RecentActivityCell(
                            expense: item.expense,
                            groupName: item.group.name,
                            paidByName: viewModel.memberName(for: item.expense.paidBy, in: item.group)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Attention

    @ViewBuilder
    private var attentionSection: some View {
        if !unsettledGroups.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(
                    title: "Needs Attention",
                    subtitle: "\(unsettledGroups.count) group\(unsettledGroups.count == 1 ? "" : "s")"
                )

                VStack(spacing: 10) {
                    ForEach(unsettledGroups.prefix(3)) { group in
                        NavigationLink(value: group.id) {
                            attentionGroupRow(group)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func attentionGroupRow(_ group: SplitGroup) -> some View {
        let debt = viewModel.calculateBalances(for: group)
            .filter { $0.amount < 0 }
            .reduce(0.0) { $0 + abs($1.amount) }

        return HStack(spacing: 14) {
            IconBadgeView(systemName: "bell.badge.fill", color: .splitDebt, size: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.black)
                Text("\(group.expenses.count) expenses • unsettled")
                    .font(.caption)
                    .foregroundColor(.splitMuted)
            }

            Spacer()

            Text(formatCurrency(debt, currency: group.currency))
                .font(.subheadline.weight(.bold))
                .foregroundColor(.splitDebt)

            CellChevron()
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(SplitGradient.debtSoft)
                .shadow(color: Color.splitDebt.opacity(0.12), radius: 6, y: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.splitDebt.opacity(0.25), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
