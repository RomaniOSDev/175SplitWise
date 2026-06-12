import Foundation

struct ExpenseFilter: Equatable {
    var searchText: String = ""
    var category: ExpenseCategory?
    var memberId: UUID?
    var dateFrom: Date?
    var dateTo: Date?

    var isActive: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty ||
        category != nil ||
        memberId != nil ||
        dateFrom != nil ||
        dateTo != nil
    }

    mutating func reset() {
        searchText = ""
        category = nil
        memberId = nil
        dateFrom = nil
        dateTo = nil
    }
}
