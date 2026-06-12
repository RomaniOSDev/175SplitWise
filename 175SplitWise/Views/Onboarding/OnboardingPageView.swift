import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 340)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [Color.clear, Color.splitBackground],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }

            VStack(spacing: 16) {
                IconBadgeView(systemName: page.icon, color: .splitCredit, size: 56)

                Text(page.title)
                    .font(.title.weight(.bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.splitMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)

            Spacer(minLength: 0)
        }
    }
}
