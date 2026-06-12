import SwiftUI

enum GroupFormMode {
    case create
    case edit(SplitGroup)
}

struct GroupFormView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    let mode: GroupFormMode
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var currency: Currency = .usd
    @State private var members: [Member] = []
    @State private var budgetText = ""
    @State private var exchangeRates: [Currency: String] = [:]

    private var editingGroup: SplitGroup? {
        if case .edit(let group) = mode { return group }
        return nil
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        members.contains { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SplitFormSection(title: "Details") {
                        SplitFormRow {
                            TextField("Group name", text: $name)
                                .tint(.splitCredit)
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            Picker("Base currency", selection: $currency) {
                                ForEach(Currency.allCases, id: \.self) { c in
                                    Text("\(c.symbol) \(c.rawValue)").tag(c)
                                }
                            }
                            .tint(.splitCredit)
                            .disabled(editingGroup != nil)
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            HStack {
                                Text("Budget limit")
                                    .foregroundColor(.splitMuted)
                                Spacer()
                                TextField("Optional", text: $budgetText)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                Text(currency.symbol)
                                    .foregroundColor(.splitMuted)
                            }
                        }
                    }

                    SplitFormSection(title: "Exchange rates") {
                        Text("1 foreign unit = X in \(currency.symbol)")
                            .font(.caption2)
                            .foregroundColor(.splitMuted)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        ForEach(Currency.allCases.filter { $0 != currency }, id: \.self) { foreign in
                            if foreign != Currency.allCases.filter({ $0 != currency }).first {
                                Divider().padding(.leading, 16)
                            }
                            SplitFormRow {
                                HStack {
                                    Text("\(foreign.symbol) \(foreign.rawValue)")
                                    Spacer()
                                    TextField("1", text: Binding(
                                        get: { exchangeRates[foreign] ?? "1" },
                                        set: { exchangeRates[foreign] = $0 }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 72)
                                    Text(currency.symbol)
                                        .font(.caption)
                                        .foregroundColor(.splitMuted)
                                }
                            }
                        }
                    }

                    SplitFormSection(title: "Members") {
                        ForEach($members) { $member in
                            SplitFormRow {
                                HStack(spacing: 12) {
                                    MemberAvatarView(name: member.name.isEmpty ? "?" : member.name, size: 36)
                                    TextField("Name", text: $member.name)
                                        .tint(.splitCredit)
                                    if members.count > 1 {
                                        Button {
                                            members.removeAll { $0.id == member.id }
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.splitDebt)
                                        }
                                    }
                                }
                            }
                            if member.id != members.last?.id {
                                Divider().padding(.leading, 16)
                            }
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            Button {
                                members.append(Member(id: UUID(), name: "", avatarColor: nil, isActive: true))
                            } label: {
                                Label("Add Member", systemImage: "plus.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.splitCredit)
                            }
                        }
                    }

                    SplitPrimaryButton(
                        title: editingGroup == nil ? "Create Group" : "Save Changes",
                        icon: "checkmark",
                        isEnabled: canSave
                    ) { save() }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .splitScreenBackground()
            .navigationTitle(editingGroup == nil ? "New Group" : "Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.splitCredit)
                }
            }
            .onAppear(perform: loadInitialState)
        }
    }

    private func loadInitialState() {
        switch mode {
        case .create:
            members = [Member(id: UUID(), name: "", avatarColor: nil, isActive: true)]
        case .edit(let group):
            name = group.name
            currency = group.currency
            members = group.members
            if let budget = group.budgetLimit {
                budgetText = String(format: "%.0f", budget)
            }
            for foreign in Currency.allCases where foreign != group.currency {
                let rate = group.exchangeRates[foreign.rawValue] ?? 1.0
                exchangeRates[foreign] = String(format: "%.4g", rate)
            }
        }
    }

    private func save() {
        let validMembers = members.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !validMembers.isEmpty else { return }

        let budget = Double(budgetText.replacingOccurrences(of: ",", with: "."))
        var rates: [String: Double] = [:]
        for foreign in Currency.allCases where foreign != currency {
            let text = exchangeRates[foreign] ?? "1"
            rates[foreign.rawValue] = Double(text.replacingOccurrences(of: ",", with: ".")) ?? 1.0
        }

        switch mode {
        case .create:
            viewModel.addGroup(SplitGroup(
                id: UUID(),
                name: name.trimmingCharacters(in: .whitespaces),
                members: validMembers,
                expenses: [],
                settlements: [],
                currency: currency,
                budgetLimit: budget,
                exchangeRates: rates,
                createdAt: Date()
            ))
        case .edit(var existing):
            existing.name = name.trimmingCharacters(in: .whitespaces)
            existing.members = validMembers
            existing.budgetLimit = budget
            existing.exchangeRates = rates
            viewModel.updateGroup(existing)
        }
        dismiss()
    }
}
