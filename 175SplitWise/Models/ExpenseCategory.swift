import Foundation

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food"
    case transport = "Transport"
    case accommodation = "Accommodation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case other = "Other"

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .accommodation: return "house.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "bag.fill"
        case .other: return "folder.fill"
        }
    }
}
