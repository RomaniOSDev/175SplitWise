import Foundation

struct SplitGroup: Identifiable, Codable {
    let id: UUID
    var name: String
    var members: [Member]
    var expenses: [Expense]
    var settlements: [Settlement]
    var currency: Currency
    var budgetLimit: Double?
    var exchangeRates: [String: Double]
    let createdAt: Date

    init(
        id: UUID,
        name: String,
        members: [Member],
        expenses: [Expense],
        settlements: [Settlement],
        currency: Currency,
        budgetLimit: Double? = nil,
        exchangeRates: [String: Double] = [:],
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
        self.settlements = settlements
        self.currency = currency
        self.budgetLimit = budgetLimit
        self.exchangeRates = exchangeRates
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        members = try c.decode([Member].self, forKey: .members)
        expenses = try c.decode([Expense].self, forKey: .expenses)
        settlements = try c.decode([Settlement].self, forKey: .settlements)
        currency = try c.decode(Currency.self, forKey: .currency)
        budgetLimit = try c.decodeIfPresent(Double.self, forKey: .budgetLimit)
        exchangeRates = try c.decodeIfPresent([String: Double].self, forKey: .exchangeRates) ?? [:]
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    var totalExpensesInBase: Double {
        expenses.reduce(0) { sum, expense in
            sum + CurrencyConverter.toBase(amount: expense.amount, from: expense.currency, group: self)
        }
    }

    var totalExpenses: Double { totalExpensesInBase }

    var budgetProgress: Double? {
        guard let limit = budgetLimit, limit > 0 else { return nil }
        return min(totalExpensesInBase / limit, 1.0)
    }

    func isSettled(balances: [Balance]) -> Bool {
        balances.allSatisfy { abs($0.amount) < 0.01 }
    }

    func exchangeRate(for currency: Currency) -> Double {
        if currency == self.currency { return 1.0 }
        return exchangeRates[currency.rawValue] ?? 1.0
    }
}
