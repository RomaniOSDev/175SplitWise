import SwiftUI

struct HomeWidgetCard: View {
    let title: String
    let value: String
    let subtitle: String
    let imageName: String
    var accentColor: Color = .splitCredit
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 88)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    SplitGradient.heroOverlay

                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                        .padding(10)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.splitMuted)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .splitCardStyle(elevation: .medium)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(accentColor.opacity(0.25), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HomeWideWidget: View {
    let title: String
    let message: String
    let value: String
    let imageName: String
    var accentColor: Color = .splitCredit
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundColor(accentColor)
                    Text(value)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.black)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.splitMuted)
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipped()
            }
            .splitCardStyle(elevation: .medium)
        }
        .buttonStyle(.plain)
    }
}
