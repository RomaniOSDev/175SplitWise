import SwiftUI

struct GroupsView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    @State private var showCreateGroupSheet = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerBanner
                    statsCarousel

                    SectionHeaderView(
                        title: "Your Groups",
                        subtitle: "\(viewModel.groups.count) active"
                    )

                    if viewModel.groups.isEmpty {
                        EmptyStateView(
                            icon: "person.3.fill",
                            title: "No groups yet",
                            message: "Create a group to start splitting expenses with friends on your next trip or event.",
                            actionTitle: "Create Group",
                            action: { showCreateGroupSheet = true }
                        )
                        .padding(.horizontal, 20)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.groups) { group in
                                NavigationLink(value: group.id) {
                                    GroupCard(
                                        group: group,
                                        balances: viewModel.calculateBalances(for: group)
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        viewModel.duplicateGroup(group)
                                    } label: {
                                        Label("Duplicate", systemImage: "plus.square.on.square")
                                    }
                                    Button(role: .destructive) {
                                        viewModel.deleteGroup(group)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 88)
                }
                .padding(.top, 8)
            }

            if !viewModel.groups.isEmpty {
                fabButton
            }
        }
        .splitScreenBackground()
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showCreateGroupSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.splitCredit)
                }
            }
        }
        .navigationDestination(for: UUID.self) { groupId in
            GroupDetailView(viewModel: viewModel, groupId: groupId)
        }
        .sheet(isPresented: $showCreateGroupSheet) {
            GroupFormView(viewModel: viewModel, mode: .create)
        }
    }

    private var headerBanner: some View {
        HStack(spacing: 14) {
            IconBadgeView(systemName: "square.split.2x2", color: .splitCredit, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text("Split smarter")
                    .font(.headline)
                    .foregroundColor(.black)
                Text("Track shared expenses and settle up fairly")
                    .font(.caption)
                    .foregroundColor(.splitMuted)
            }
            Spacer()
        }
        .padding(16)
        .splitCardStyle(elevation: .low)
        .padding(.horizontal, 20)
    }

    private var statsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(title: "Groups", value: "\(viewModel.groups.count)", icon: "person.3.fill", color: .splitCredit, compact: true)
                    .frame(width: 140)
                StatCard(title: "Debt", value: formatCurrency(viewModel.totalDebt), icon: "exclamationmark.circle.fill", color: .splitDebt, compact: true)
                    .frame(width: 140)
                StatCard(title: "Settled", value: formatCurrency(viewModel.totalSettled), icon: "checkmark.circle.fill", color: .splitCredit, compact: true)
                    .frame(width: 140)
                StatCard(title: "Members", value: "\(viewModel.totalMembers)", icon: "person.fill", color: .splitCredit, compact: true)
                    .frame(width: 140)
            }
            .padding(.horizontal, 20)
        }
    }

    private var fabButton: some View {
        Button { showCreateGroupSheet = true } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background {
                    Circle()
                        .fill(SplitGradient.creditButton)
                        .shadow(color: Color.splitCredit.opacity(0.35), radius: 10, y: 5)
                }
        }
        .padding(.trailing, 24)
        .padding(.bottom, 24)
    }
}
