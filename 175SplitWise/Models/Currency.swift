import Foundation

enum Currency: String, CaseIterable, Codable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case cny = "CNY"

    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .cny: return "¥"
        }
    }
}
