import Foundation

enum SplitType: String, CaseIterable, Codable {
    case equal = "Split equally"
    case exactAmount = "Exact amounts"
    case percentage = "By percentage"
    case singlePayer = "All on one person"

    var shortLabel: String {
        switch self {
        case .equal: return "Equal"
        case .exactAmount: return "Amount"
        case .percentage: return "%"
        case .singlePayer: return "One person"
        }
    }
}
