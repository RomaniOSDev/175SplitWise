import Foundation

struct Settlement: Identifiable, Codable {
    let id: UUID
    var fromMemberId: UUID
    var toMemberId: UUID
    var amount: Double
    var date: Date
    var notes: String?
    var isCompleted: Bool
}
