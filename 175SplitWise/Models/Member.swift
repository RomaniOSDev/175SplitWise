import Foundation

struct Member: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatarColor: String?
    var isActive: Bool

    var balance: Double { 0 }
}
