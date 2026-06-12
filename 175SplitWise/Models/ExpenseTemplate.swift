import Foundation

struct ExpenseTemplate: Identifiable, Codable {
    let id: UUID
    var title: String
    var category: ExpenseCategory
    var splitType: SplitType
    var defaultAmount: Double?
}
