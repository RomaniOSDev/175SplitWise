import Foundation
import Combine

struct SuggestedSettlement: Identifiable {
    let id = UUID()
    let fromMemberId: UUID
    let fromMemberName: String
    let toMemberId: UUID
    let toMemberName: String
    let amount: Double
}

final class SplitWiseViewModel: ObservableObject {
    @Published var groups: [SplitGroup] = []
    @Published var expenseTemplates: [ExpenseTemplate] = []

    var totalMembers: Int {
        groups.reduce(0) { $0 + $1.members.count }
    }

    var totalExpenses: Int {
        groups.reduce(0) { $0 + $1.expenses.count }
    }

    var totalAmount: Double {
        groups.reduce(0) { $0 + $1.totalExpensesInBase }
    }

    var totalDebt: Double {
        var debt = 0.0
        for group in groups {
            let balances = calculateBalances(for: group)
            debt += balances.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        }
        return debt
    }

    var totalSettled: Double {
        max(totalAmount - totalDebt, 0)
    }

    // MARK: - Balances

    func calculateBalances(for group: SplitGroup) -> [Balance] {
        var balances: [UUID: Double] = [:]

        for member in group.members {
            balances[member.id] = 0
        }

        for expense in group.expenses {
            let paidBase = CurrencyConverter.toBase(amount: expense.amount, from: expense.currency, group: group)
            balances[expense.paidBy, default: 0] += paidBase

            for split in expense.splits {
                let shareBase = CurrencyConverter.toBase(amount: split.amount, from: expense.currency, group: group)
                balances[split.memberId, default: 0] -= shareBase
            }
        }

        for settlement in group.settlements where settlement.isCompleted {
            balances[settlement.fromMemberId, default: 0] += settlement.amount
            balances[settlement.toMemberId, default: 0] -= settlement.amount
        }

        return balances.compactMap { memberId, amount in
            guard let member = group.members.first(where: { $0.id == memberId }) else { return nil }
            return Balance(memberId: memberId, memberName: member.name, amount: amount)
        }
    }

    func balances(for group: SplitGroup) -> [Balance] {
        calculateBalances(for: group)
            .filter { abs($0.amount) > 0.01 }
            .sorted { abs($0.amount) > abs($1.amount) }
    }

    func filteredExpenses(for group: SplitGroup, filter: ExpenseFilter) -> [Expense] {
        group.expenses
            .filter { matchesFilter($0, in: group, filter: filter) }
            .sorted { $0.date > $1.date }
    }

    func filteredExpensesAllGroups(filter: ExpenseFilter) -> [Expense] {
        groups.flatMap { group in
            filteredExpenses(for: group, filter: filter)
        }
    }

    private func matchesFilter(_ expense: Expense, in group: SplitGroup, filter: ExpenseFilter) -> Bool {
        let query = filter.searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if !query.isEmpty {
            let inTitle = expense.title.lowercased().contains(query)
            let inNotes = expense.notes?.lowercased().contains(query) ?? false
            let inCategory = expense.category.rawValue.lowercased().contains(query)
            if !inTitle && !inNotes && !inCategory { return false }
        }

        if let category = filter.category, expense.category != category { return false }

        if let memberId = filter.memberId {
            let involved = expense.paidBy == memberId ||
                expense.splits.contains { $0.memberId == memberId }
            if !involved { return false }
        }

        if let from = filter.dateFrom {
            let start = Calendar.current.startOfDay(for: from)
            if expense.date < start { return false }
        }

        if let to = filter.dateTo {
            let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: to) ?? to
            if expense.date > end { return false }
        }

        return true
    }

    func recentExpenses(for group: SplitGroup, filter: ExpenseFilter = ExpenseFilter()) -> [Expense] {
        Array(filteredExpenses(for: group, filter: filter).prefix(50))
    }

    func memberName(for memberId: UUID, in group: SplitGroup) -> String? {
        group.members.first { $0.id == memberId }?.name
    }

    func completedSettlements(for group: SplitGroup) -> [Settlement] {
        group.settlements
            .filter { $0.isCompleted }
            .sorted { $0.date > $1.date }
    }

    struct MemberExpenseStat: Identifiable {
        var id: UUID { memberId }
        let memberId: UUID
        let memberName: String
        let totalPaid: Double
        let totalShare: Double
        var netContribution: Double { totalPaid - totalShare }
    }

    func memberStats(for group: SplitGroup) -> [MemberExpenseStat] {
        group.members.map { member in
            var paid = 0.0
            var share = 0.0

            for expense in group.expenses {
                if expense.paidBy == member.id {
                    paid += CurrencyConverter.toBase(amount: expense.amount, from: expense.currency, group: group)
                }
                if let split = expense.splits.first(where: { $0.memberId == member.id }) {
                    share += CurrencyConverter.toBase(amount: split.amount, from: expense.currency, group: group)
                }
            }

            return MemberExpenseStat(
                memberId: member.id,
                memberName: member.name,
                totalPaid: paid,
                totalShare: share
            )
        }
        .sorted { $0.totalShare > $1.totalShare }
    }

    struct GroupMonthlyRank: Identifiable {
        let id: String
        let groupId: UUID
        let groupName: String
        let monthLabel: String
        let amount: Double
        let currency: Currency
        let sortDate: Date
    }

    func topGroupsByMonth(limit: Int = 10) -> [GroupMonthlyRank] {
        let calendar = Calendar.current
        var ranks: [GroupMonthlyRank] = []

        for group in groups {
            let grouped = Dictionary(grouping: group.expenses) { expense in
                calendar.dateComponents([.year, .month], from: expense.date)
            }

            for (components, expenses) in grouped {
                guard let date = calendar.date(from: components) else { continue }
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                let amount = expenses.reduce(0.0) {
                    $0 + CurrencyConverter.toBase(amount: $1.amount, from: $1.currency, group: group)
                }
                ranks.append(GroupMonthlyRank(
                    id: "\(group.id)-\(components.year ?? 0)-\(components.month ?? 0)",
                    groupId: group.id,
                    groupName: group.name,
                    monthLabel: formatter.string(from: date),
                    amount: amount,
                    currency: group.currency,
                    sortDate: date
                ))
            }
        }

        return ranks.sorted { $0.amount > $1.amount }.prefix(limit).map { $0 }
    }

    // MARK: - Settlements

    func suggestedSettlements(for group: SplitGroup) -> [SuggestedSettlement] {
        let balances = calculateBalances(for: group)
        var debtors = balances
            .filter { $0.amount < -0.01 }
            .map { (memberId: $0.memberId, memberName: $0.memberName, amount: -$0.amount) }
        var creditors = balances
            .filter { $0.amount > 0.01 }
            .map { (memberId: $0.memberId, memberName: $0.memberName, amount: $0.amount) }

        var settlements: [SuggestedSettlement] = []
        var i = 0
        var j = 0

        while i < debtors.count && j < creditors.count {
            let amount = min(debtors[i].amount, creditors[j].amount)

            settlements.append(SuggestedSettlement(
                fromMemberId: debtors[i].memberId,
                fromMemberName: debtors[i].memberName,
                toMemberId: creditors[j].memberId,
                toMemberName: creditors[j].memberName,
                amount: amount
            ))

            debtors[i].amount -= amount
            creditors[j].amount -= amount

            if debtors[i].amount < 0.01 { i += 1 }
            if creditors[j].amount < 0.01 { j += 1 }
        }

        return settlements
    }

    // MARK: - CRUD

    func group(with id: UUID) -> SplitGroup? {
        groups.first { $0.id == id }
    }

    func addGroup(_ group: SplitGroup) {
        groups.append(group)
        saveToUserDefaults()
    }

    func updateGroup(_ group: SplitGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            saveToUserDefaults()
        }
    }

    func deleteGroup(_ group: SplitGroup) {
        groups.removeAll { $0.id == group.id }
        saveToUserDefaults()
    }

    func duplicateGroup(_ group: SplitGroup) {
        let newGroup = SplitGroup(
            id: UUID(),
            name: "\(group.name) (copy)",
            members: group.members.map {
                Member(id: UUID(), name: $0.name, avatarColor: $0.avatarColor, isActive: $0.isActive)
            },
            expenses: [],
            settlements: [],
            currency: group.currency,
            budgetLimit: group.budgetLimit,
            exchangeRates: group.exchangeRates,
            createdAt: Date()
        )
        groups.append(newGroup)
        saveToUserDefaults()
    }

    func addExpense(to groupId: UUID, expense: Expense) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].expenses.append(expense)
            saveToUserDefaults()
        }
    }

    func updateExpense(in groupId: UUID, expense: Expense) {
        if let gIndex = groups.firstIndex(where: { $0.id == groupId }),
           let eIndex = groups[gIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            groups[gIndex].expenses[eIndex] = expense
            saveToUserDefaults()
        }
    }

    func deleteExpense(from groupId: UUID, expense: Expense) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].expenses.removeAll { $0.id == expense.id }
            saveToUserDefaults()
        }
    }

    func addSettlement(to groupId: UUID, settlement: Settlement) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].settlements.append(settlement)
            saveToUserDefaults()
        }
    }

    func recordSettlement(for groupId: UUID, suggestion: SuggestedSettlement) {
        let settlement = Settlement(
            id: UUID(),
            fromMemberId: suggestion.fromMemberId,
            toMemberId: suggestion.toMemberId,
            amount: suggestion.amount,
            date: Date(),
            notes: nil,
            isCompleted: true
        )
        addSettlement(to: groupId, settlement: settlement)
    }

    // MARK: - Templates

    func addTemplate(_ template: ExpenseTemplate) {
        expenseTemplates.append(template)
        saveTemplates()
    }

    func deleteTemplate(_ template: ExpenseTemplate) {
        expenseTemplates.removeAll { $0.id == template.id }
        saveTemplates()
    }

    func saveAsTemplate(title: String, category: ExpenseCategory, splitType: SplitType, amount: Double?) {
        let template = ExpenseTemplate(
            id: UUID(),
            title: title,
            category: category,
            splitType: splitType,
            defaultAmount: amount
        )
        addTemplate(template)
    }

    // MARK: - Export

    func exportText(for group: SplitGroup) -> String {
        ExportReportBuilder.buildText(for: group, viewModel: self)
    }

    // MARK: - Statistics

    struct ExpenseCategoryStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let amount: Double
        let percentage: Double
    }

    func expenseByCategory(filter: ExpenseFilter = ExpenseFilter()) -> [ExpenseCategoryStat] {
        var allExpenses: [(Expense, SplitGroup)] = []
        for group in groups {
            for expense in filteredExpenses(for: group, filter: filter) {
                allExpenses.append((expense, group))
            }
        }

        let grouped = Dictionary(grouping: allExpenses, by: { $0.0.category })
        let total = allExpenses.reduce(0.0) {
            $0 + CurrencyConverter.toBase(amount: $1.0.amount, from: $1.0.currency, group: $1.1)
        }

        return grouped.map { category, items in
            let amount = items.reduce(0.0) {
                $0 + CurrencyConverter.toBase(amount: $1.0.amount, from: $1.0.currency, group: $1.1)
            }
            return ExpenseCategoryStat(
                name: category.rawValue,
                icon: category.icon,
                amount: amount,
                percentage: total > 0 ? amount / total * 100 : 0
            )
        }.sorted { $0.amount > $1.amount }
    }

    struct MonthlyExpense: Identifiable {
        let id = UUID()
        let month: String
        let amount: Double
        let sortDate: Date
    }

    func monthlyExpenses(filter: ExpenseFilter = ExpenseFilter()) -> [MonthlyExpense] {
        let calendar = Calendar.current
        var items: [(Date, Double)] = []

        for group in groups {
            for expense in filteredExpenses(for: group, filter: filter) {
                let components = calendar.dateComponents([.year, .month], from: expense.date)
                let monthDate = calendar.date(from: components) ?? expense.date
                let base = CurrencyConverter.toBase(amount: expense.amount, from: expense.currency, group: group)
                items.append((monthDate, base))
            }
        }

        let grouped = Dictionary(grouping: items, by: { $0.0 })
        return grouped.map { date, pairs in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return MonthlyExpense(
                month: formatter.string(from: date),
                amount: pairs.reduce(0) { $0 + $1.1 },
                sortDate: date
            )
        }.sorted { $0.sortDate < $1.sortDate }
    }

    func memberStatsAllGroups(filter: ExpenseFilter = ExpenseFilter()) -> [MemberExpenseStat] {
        var byMember: [String: (id: UUID, paid: Double, share: Double)] = [:]

        for group in groups {
            for expense in filteredExpenses(for: group, filter: filter) {
                let paidBase = CurrencyConverter.toBase(amount: expense.amount, from: expense.currency, group: group)
                if let name = memberName(for: expense.paidBy, in: group) {
                    var entry = byMember[name] ?? (expense.paidBy, 0, 0)
                    entry.paid += paidBase
                    byMember[name] = entry
                }
                for split in expense.splits {
                    if let name = memberName(for: split.memberId, in: group) {
                        let shareBase = CurrencyConverter.toBase(amount: split.amount, from: expense.currency, group: group)
                        var entry = byMember[name] ?? (split.memberId, 0, 0)
                        entry.share += shareBase
                        byMember[name] = entry
                    }
                }
            }
        }

        return byMember.map { name, data in
            MemberExpenseStat(memberId: data.id, memberName: name, totalPaid: data.paid, totalShare: data.share)
        }.sorted { $0.totalShare > $1.totalShare }
    }

    // MARK: - Persistence

    private let groupsKey = "splitwise_groups"
    private let templatesKey = "splitwise_templates"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: groupsKey)
        }
    }

    private func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(expenseTemplates) {
            UserDefaults.standard.set(encoded, forKey: templatesKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([SplitGroup].self, from: data) {
            groups = decoded
        }

        if let data = UserDefaults.standard.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([ExpenseTemplate].self, from: data) {
            expenseTemplates = decoded
        }

        if groups.isEmpty {
            loadDemoData()
        }
    }

    private func loadDemoData() {
        let member1 = Member(id: UUID(), name: "Alex", avatarColor: nil, isActive: true)
        let member2 = Member(id: UUID(), name: "Maria", avatarColor: nil, isActive: true)
        let member3 = Member(id: UUID(), name: "Dmitry", avatarColor: nil, isActive: true)

        let split1 = Split(id: UUID(), memberId: member1.id, amount: 1500, isPaid: false)
        let split2 = Split(id: UUID(), memberId: member2.id, amount: 1500, isPaid: false)
        let split3 = Split(id: UUID(), memberId: member3.id, amount: 1500, isPaid: false)

        let expense = Expense(
            id: UUID(),
            title: "Dinner at restaurant",
            amount: 4500,
            currency: .rub,
            category: .food,
            paidBy: member1.id,
            date: Date().addingTimeInterval(-86400 * 2),
            splits: [split1, split2, split3],
            splitType: .equal,
            notes: "Great restaurant",
            receiptImage: nil,
            createdAt: Date()
        )

        let group = SplitGroup(
            id: UUID(),
            name: "Mountain Trip",
            members: [member1, member2, member3],
            expenses: [expense],
            settlements: [],
            currency: .rub,
            budgetLimit: 10000,
            exchangeRates: ["USD": 90, "EUR": 100],
            createdAt: Date()
        )

        groups = [group]

        expenseTemplates = [
            ExpenseTemplate(id: UUID(), title: "Taxi", category: .transport, splitType: .equal, defaultAmount: nil),
            ExpenseTemplate(id: UUID(), title: "Dinner", category: .food, splitType: .equal, defaultAmount: nil)
        ]
    }
}
