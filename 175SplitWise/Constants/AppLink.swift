import Foundation

enum AppLink: String, CaseIterable {
    case privacyPolicy = "https://www.termsfeed.com/live/36027e1c-85a1-472f-800b-d4eaeb04c7d8"
    case termsOfUse = "https://www.termsfeed.com/live/96c32542-3b5d-4210-8b6e-9c035e6e6ef5"

    var url: URL? {
        URL(string: rawValue)
    }

    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfUse: return "Terms of Use"
        }
    }

    var icon: String {
        switch self {
        case .privacyPolicy: return "hand.raised.fill"
        case .termsOfUse: return "doc.text.fill"
        }
    }
}
