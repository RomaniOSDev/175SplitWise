import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            IconBadgeView(systemName: icon, color: color, size: compact ? 36 : 40)
            Text(title)
                .font(.caption)
                .foregroundColor(.splitMuted)
                .lineLimit(1)
            Text(value)
                .font(compact ? .title3.weight(.bold) : .title2.weight(.bold))
                .foregroundColor(.black)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(compact ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .splitCardStyle(elevation: .low)
    }
}
