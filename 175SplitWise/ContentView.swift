import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SplitWiseViewModel()
    @State private var selectedTab = 0
    @State private var showOnboarding = !OnboardingStorage.hasCompleted

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.splitBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                MainTabView(viewModel: viewModel, selectedTab: $selectedTab)
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
            showOnboarding = !OnboardingStorage.hasCompleted
        }
    }
}

#Preview("Main") {
    ContentView()
}

#Preview("Onboarding") {
    OnboardingView(onFinish: {})
}
