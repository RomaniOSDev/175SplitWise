import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var currentPage = 0

    private let pages = OnboardingPage.pages
    private var isLastPage: Bool { currentPage == pages.count - 1 }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: currentPage)

                bottomBar
            }

            if !isLastPage {
                Button("Skip") {
                    finishOnboarding()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.splitCredit)
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .splitScreenBackground()
    }

    private var bottomBar: some View {
        VStack(spacing: 20) {
            pageIndicator

            if isLastPage {
                SplitPrimaryButton(title: "Get Started", icon: "arrow.right") {
                    finishOnboarding()
                }
                .padding(.horizontal, 24)
            } else {
                SplitPrimaryButton(title: "Next", icon: "chevron.right") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentPage += 1
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 36)
        .padding(.top, 8)
        .background {
            Color.splitBackground
                .shadow(color: Color.splitShadow, radius: 8, y: -4)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Capsule()
                    .fill(page.id == currentPage ? Color.splitCredit : Color.splitCredit.opacity(0.2))
                    .frame(width: page.id == currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private func finishOnboarding() {
        OnboardingStorage.markCompleted()
        onFinish()
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
