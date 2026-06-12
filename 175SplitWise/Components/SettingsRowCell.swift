import SwiftUI

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var iconColor: Color = .splitCredit
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadgeView(systemName: icon, color: iconColor, size: 44)
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.splitMuted.opacity(0.6))
            }
            .padding(14)
            .splitCardStyle(cornerRadius: 14, elevation: .low)
        }
        .buttonStyle(.plain)
    }
}
