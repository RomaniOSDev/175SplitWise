import Foundation

struct Balance: Identifiable {
    var id: UUID { memberId }
    var memberId: UUID
    var memberName: String
    var amount: Double
}
