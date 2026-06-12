import Foundation

enum SplitCalculator {
    static func computeSplits(
        amount: Double,
        splitType: SplitType,
        members: [Member],
        splitValues: [UUID: Double],
        singlePayerId: UUID?
    ) -> [UUID: Double] {
        guard !members.isEmpty, amount > 0 else {
            return Dictionary(uniqueKeysWithValues: members.map { ($0.id, 0) })
        }

        switch splitType {
        case .equal:
            let share = amount / Double(members.count)
            return Dictionary(uniqueKeysWithValues: members.map { ($0.id, share) })

        case .exactAmount:
            return Dictionary(uniqueKeysWithValues: members.map { ($0.id, splitValues[$0.id, default: 0]) })

        case .percentage:
            return Dictionary(uniqueKeysWithValues: members.map { member in
                let pct = splitValues[member.id, default: 0]
                return (member.id, amount * pct / 100)
            })

        case .singlePayer:
            let payer = singlePayerId ?? members[0].id
            return Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0.id == payer ? amount : 0) })
        }
    }

    static func defaultSplitValues(
        splitType: SplitType,
        members: [Member],
        amount: Double
    ) -> [UUID: Double] {
        switch splitType {
        case .equal, .exactAmount, .singlePayer:
            let share = members.isEmpty ? 0 : amount / Double(members.count)
            return Dictionary(uniqueKeysWithValues: members.map { ($0.id, share) })
        case .percentage:
            let pct = members.isEmpty ? 0 : 100.0 / Double(members.count)
            return Dictionary(uniqueKeysWithValues: members.map { ($0.id, pct) })
        }
    }
}
