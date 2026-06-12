import SwiftUI

struct ExpenseFilterBar: View {
    @Binding var filter: ExpenseFilter
    let members: [Member]
    var onFilterChange: () -> Void = {}

    @State private var showFilters = false

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.splitCredit)
                    TextField("Search expenses…", text: $filter.searchText)
                        .foregroundColor(.black)
                        .onChange(of: filter.searchText) { _ in onFilterChange() }

                    if filter.isActive {
                        Button {
                            filter.reset()
                            onFilterChange()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.splitMuted)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .splitCardStyle(
                    cornerRadius: 14,
                    elevation: .low,
                    padding: 0
                )
                .overlay {
                    if filter.isActive {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.splitCredit.opacity(0.35), lineWidth: 1)
                    }
                }

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        showFilters.toggle()
                    }
                } label: {
                    Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(SplitGradient.creditButton)
                                .shadow(color: Color.splitCredit.opacity(0.28), radius: 6, y: 3)
                        }
                }
            }

            if showFilters {
                SplitCard(elevation: .low) {
                    VStack(spacing: 14) {
                        filterPicker(
                            title: "Category",
                            selection: Binding(
                                get: { filter.category },
                                set: { filter.category = $0; onFilterChange() }
                            )
                        ) {
                            Text("All categories").tag(Optional<ExpenseCategory>.none)
                            ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(Optional(cat))
                            }
                        }

                        filterPicker(
                            title: "Member",
                            selection: Binding(
                                get: { filter.memberId },
                                set: { filter.memberId = $0; onFilterChange() }
                            )
                        ) {
                            Text("All members").tag(Optional<UUID>.none)
                            ForEach(members) { member in
                                Text(member.name).tag(Optional(member.id))
                            }
                        }

                        DatePicker("From", selection: Binding(
                            get: { filter.dateFrom ?? Date.distantPast },
                            set: { filter.dateFrom = $0; onFilterChange() }
                        ), displayedComponents: .date)
                        .tint(.splitCredit)

                        DatePicker("To", selection: Binding(
                            get: { filter.dateTo ?? Date() },
                            set: { filter.dateTo = $0; onFilterChange() }
                        ), displayedComponents: .date)
                        .tint(.splitCredit)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 20)
    }

    private func filterPicker<Selection: Hashable, Content: View>(
        title: String,
        selection: Binding<Selection>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.splitMuted)
            Picker(title, selection: selection, content: content)
                .tint(.splitCredit)
        }
    }
}
