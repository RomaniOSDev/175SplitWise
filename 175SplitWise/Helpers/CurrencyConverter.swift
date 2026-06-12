import Foundation

enum CurrencyConverter {
    static func toBase(amount: Double, from currency: Currency, group: SplitGroup) -> Double {
        if currency == group.currency { return amount }
        let rate = group.exchangeRates[currency.rawValue] ?? 1.0
        return amount * rate
    }

    static func formatInBase(_ amount: Double, group: SplitGroup) -> String {
        formatCurrency(amount, currency: group.currency)
    }
}
