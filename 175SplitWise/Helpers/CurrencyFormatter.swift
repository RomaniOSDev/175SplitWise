import Foundation

func formatCurrency(_ amount: Double, currency: Currency = .rub) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    formatter.maximumFractionDigits = 0
    return (formatter.string(from: NSNumber(value: amount)) ?? "0") + " \(currency.symbol)"
}
