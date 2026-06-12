import Foundation

struct Split: Identifiable, Codable {
    let id: UUID
    var memberId: UUID
    var amount: Double
    var isPaid: Bool
}
