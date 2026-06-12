import Foundation

struct Expense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var currency: Currency
    var category: ExpenseCategory
    var paidBy: UUID
    var date: Date
    var splits: [Split]
    var splitType: SplitType
    var notes: String?
    var receiptImage: String?
    let createdAt: Date

    init(
        id: UUID,
        title: String,
        amount: Double,
        currency: Currency,
        category: ExpenseCategory,
        paidBy: UUID,
        date: Date,
        splits: [Split],
        splitType: SplitType = .equal,
        notes: String?,
        receiptImage: String?,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.category = category
        self.paidBy = paidBy
        self.date = date
        self.splits = splits
        self.splitType = splitType
        self.notes = notes
        self.receiptImage = receiptImage
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        amount = try c.decode(Double.self, forKey: .amount)
        currency = try c.decode(Currency.self, forKey: .currency)
        category = try c.decode(ExpenseCategory.self, forKey: .category)
        paidBy = try c.decode(UUID.self, forKey: .paidBy)
        date = try c.decode(Date.self, forKey: .date)
        splits = try c.decode([Split].self, forKey: .splits)
        splitType = try c.decodeIfPresent(SplitType.self, forKey: .splitType) ?? .equal
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        receiptImage = try c.decodeIfPresent(String.self, forKey: .receiptImage)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}
