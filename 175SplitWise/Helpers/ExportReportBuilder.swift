import Foundation
import UIKit

enum ExportReportBuilder {
    static func buildText(for group: SplitGroup, viewModel: SplitWiseViewModel) -> String {
        var lines: [String] = []
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        lines.append("GROUP REPORT")
        lines.append("============")
        lines.append("Name: \(group.name)")
        lines.append("Base currency: \(group.currency.symbol) \(group.currency.rawValue)")
        lines.append("Generated: \(formatter.string(from: Date()))")
        lines.append("")

        if let budget = group.budgetLimit {
            lines.append("Budget: \(formatCurrency(budget, currency: group.currency))")
            lines.append("Spent: \(formatCurrency(group.totalExpensesInBase, currency: group.currency))")
            lines.append("")
        }

        lines.append("BALANCES")
        lines.append("--------")
        let balances = viewModel.calculateBalances(for: group)
        if balances.allSatisfy({ abs($0.amount) < 0.01 }) {
            lines.append("All settled.")
        } else {
            for b in balances.sorted(by: { abs($0.amount) > abs($1.amount) }) {
                if abs(b.amount) < 0.01 { continue }
                if b.amount > 0 {
                    lines.append("\(b.memberName): +\(formatCurrency(b.amount, currency: group.currency)) (is owed)")
                } else {
                    lines.append("\(b.memberName): \(formatCurrency(abs(b.amount), currency: group.currency)) (owes)")
                }
            }
        }
        lines.append("")

        lines.append("SUGGESTED TRANSFERS")
        lines.append("-------------------")
        let suggestions = viewModel.suggestedSettlements(for: group)
        if suggestions.isEmpty {
            lines.append("None — all accounts settled.")
        } else {
            for s in suggestions {
                lines.append("\(s.fromMemberName) → \(s.toMemberName): \(formatCurrency(s.amount, currency: group.currency))")
            }
        }
        lines.append("")

        lines.append("MEMBER ACTIVITY")
        lines.append("---------------")
        for stat in viewModel.memberStats(for: group) {
            lines.append("\(stat.memberName)")
            lines.append("  Paid: \(formatCurrency(stat.totalPaid, currency: group.currency))")
            lines.append("  Share: \(formatCurrency(stat.totalShare, currency: group.currency))")
        }
        lines.append("")

        lines.append("EXPENSES")
        lines.append("--------")
        let expenses = group.expenses.sorted { $0.date > $1.date }
        if expenses.isEmpty {
            lines.append("No expenses.")
        } else {
            for expense in expenses {
                let paidBy = viewModel.memberName(for: expense.paidBy, in: group) ?? "?"
                let base = CurrencyConverter.toBase(amount: expense.amount, from: expense.currency, group: group)
                let currLabel = expense.currency == group.currency ? "" : " (\(expense.currency.symbol))"
                lines.append("• \(expense.title) — \(formatCurrency(expense.amount, currency: expense.currency))\(currLabel)")
                lines.append("  \(expense.category.rawValue) | \(formatter.string(from: expense.date)) | Paid by \(paidBy)")
                lines.append("  In base: \(formatCurrency(base, currency: group.currency))")
            }
        }
        lines.append("")

        let completed = viewModel.completedSettlements(for: group)
        if !completed.isEmpty {
            lines.append("SETTLEMENT HISTORY")
            lines.append("------------------")
            for s in completed {
                let from = viewModel.memberName(for: s.fromMemberId, in: group) ?? "?"
                let to = viewModel.memberName(for: s.toMemberId, in: group) ?? "?"
                lines.append("\(formatter.string(from: s.date)): \(from) → \(to) \(formatCurrency(s.amount, currency: group.currency))")
            }
        }

        return lines.joined(separator: "\n")
    }

    static func buildPDFData(for group: SplitGroup, viewModel: SplitWiseViewModel) -> Data {
        let text = buildText(for: group, viewModel: viewModel)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
            ]
            let drawRect = CGRect(x: 40, y: 40, width: 532, height: 700)
            text.draw(in: drawRect, withAttributes: attributes)
        }
    }

    static func pdfFileURL(for group: SplitGroup, viewModel: SplitWiseViewModel) -> URL? {
        let data = buildPDFData(for: group, viewModel: viewModel)
        let safeName = group.name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeName)-report.pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
