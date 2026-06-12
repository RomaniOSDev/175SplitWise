import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                    .navigationDestination(for: UUID.self) { groupId in
                        GroupDetailView(viewModel: viewModel, groupId: groupId)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                GroupsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Groups", systemImage: "person.3.fill")
            }
            .tag(1)

            NavigationStack {
                StatsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.fill")
            }
            .tag(2)

            NavigationStack {
                SettingsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(.splitCredit)
    }
}
