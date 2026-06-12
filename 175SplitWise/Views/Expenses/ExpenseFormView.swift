import SwiftUI

enum ExpenseFormMode {
    case add(template: ExpenseTemplate? = nil)
    case edit(Expense)
}

struct ExpenseFormView: View {
    @ObservedObject var viewModel: SplitWiseViewModel
    let group: SplitGroup
    let mode: ExpenseFormMode
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amount: Double = 0
    @State private var expenseCurrency: Currency = .usd
    @State private var category: ExpenseCategory = .food
    @State private var paidBy: UUID
    @State private var date = Date()
    @State private var splitType: SplitType = .equal
    @State private var splitValues: [UUID: Double] = [:]
    @State private var singlePayerId: UUID?
    @State private var notes = ""
    @State private var saveAsTemplate = false

    private var editingExpense: Expense? {
        if case .edit(let expense) = mode { return expense }
        return nil
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0
    }

    init(viewModel: SplitWiseViewModel, group: SplitGroup, mode: ExpenseFormMode) {
        self.viewModel = viewModel
        self.group = group
        self.mode = mode
        _paidBy = State(initialValue: group.members.first?.id ?? UUID())
        _expenseCurrency = State(initialValue: group.currency)
        _singlePayerId = State(initialValue: group.members.first?.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    templatesSection

                    SplitFormSection(title: "Expense") {
                        SplitFormRow {
                            TextField("Title", text: $title).tint(.splitCredit)
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            HStack {
                                Text("Amount").foregroundColor(.splitMuted)
                                Spacer()
                                TextField("0", value: $amount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                Text(expenseCurrency.symbol).foregroundColor(.splitMuted)
                            }
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            Picker("Currency", selection: $expenseCurrency) {
                                ForEach(Currency.allCases, id: \.self) { c in
                                    Text("\(c.symbol) \(c.rawValue)").tag(c)
                                }
                            }
                            .tint(.splitCredit)
                        }
                        if expenseCurrency != group.currency {
                            SplitFormRow {
                                HStack {
                                    Text("In base").foregroundColor(.splitMuted)
                                    Spacer()
                                    Text(formatCurrency(
                                        CurrencyConverter.toBase(amount: amount, from: expenseCurrency, group: group),
                                        currency: group.currency
                                    ))
                                    .foregroundColor(.splitCredit)
                                    .fontWeight(.semibold)
                                }
                            }
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            Picker("Category", selection: $category) {
                                ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                                }
                            }
                            .tint(.splitCredit)
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            Picker("Paid by", selection: $paidBy) {
                                ForEach(group.members) { Text($0.name).tag($0.id) }
                            }
                            .tint(.splitCredit)
                        }
                        Divider().padding(.leading, 16)
                        SplitFormRow {
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .tint(.splitCredit)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("SPLIT TYPE")
                            .font(.caption.weight(.bold))
                            .tracking(0.6)
                            .foregroundColor(.splitMuted)
                            .padding(.leading, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SplitType.allCases, id: \.self) { type in
                                    Button {
                                        splitType = type
                                        applySplitType()
                                    } label: {
                                        Text(type.shortLabel)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .foregroundColor(splitType == type ? .white : .splitCredit)
                                            .background(splitType == type ? Color.splitCredit : Color.splitCredit.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    SplitFormSection(title: "Split between") {
                        if splitType == .singlePayer {
                            SplitFormRow {
                                Picker("Assign to", selection: Binding(
                                    get: { singlePayerId ?? group.members.first?.id ?? UUID() },
                                    set: { singlePayerId = $0 }
                                )) {
                                    ForEach(group.members) { Text($0.name).tag($0.id) }
                                }
                                .tint(.splitCredit)
                            }
                        } else {
                            ForEach(group.members) { member in
                                SplitFormRow {
                                    splitRow(for: member)
                                }
                                if member.id != group.members.last?.id {
                                    Divider().padding(.leading, 16)
                                }
                            }
                            if splitType != .singlePayer {
                                Divider().padding(.leading, 16)
                                SplitFormRow {
                                    Button { applySplitType() } label: {
                                        Label("Recalculate", systemImage: "arrow.triangle.2.circlepath")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.splitCredit)
                                    }
                                }
                            }
                        }
                    }

                    SplitFormSection(title: "Notes") {
                        SplitFormRow {
                            TextEditor(text: $notes)
                                .frame(height: 88)
                                .tint(.splitCredit)
                        }
                        if editingExpense == nil {
                            Divider().padding(.leading, 16)
                            SplitFormRow {
                                Toggle("Save as template", isOn: $saveAsTemplate)
                                    .tint(.splitCredit)
                            }
                        }
                    }

                    SplitPrimaryButton(title: "Save Expense", icon: "checkmark", isEnabled: canSave) {
                        saveExpense()
                    }
                }
                .padding(20)
            }
            .splitScreenBackground()
            .navigationTitle(editingExpense == nil ? "New Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.splitCredit)
                }
            }
            .onAppear(perform: loadInitialState)
            .onChange(of: amount) { _ in applySplitType() }
        }
    }

    @ViewBuilder
    private var templatesSection: some View {
        if editingExpense == nil, !viewModel.expenseTemplates.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("QUICK TEMPLATES")
                    .font(.caption.weight(.bold))
                    .tracking(0.6)
                    .foregroundColor(.splitMuted)
                    .padding(.leading, 4)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.expenseTemplates) { template in
                            Button { applyTemplate(template) } label: {
                                HStack(spacing: 8) {
                                    IconBadgeView(systemName: template.category.icon, color: .splitCredit, size: 32)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(template.title)
                                            .font(.caption.weight(.bold))
                                        Text(template.splitType.shortLabel)
                                            .font(.caption2)
                                            .foregroundColor(.splitMuted)
                                    }
                                }
                                .padding(10)
                                .splitCardStyle(cornerRadius: 12, elevation: .low)
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func splitRow(for member: Member) -> some View {
        HStack(spacing: 12) {
            MemberAvatarView(name: member.name, size: 32)
            Text(member.name)
            Spacer()
            if splitType == .percentage {
                TextField("0", value: Binding(
                    get: { splitValues[member.id, default: 0] },
                    set: { splitValues[member.id] = $0 }
                ), format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 56)
                .multilineTextAlignment(.trailing)
                Text("%").foregroundColor(.splitMuted)
            } else {
                TextField("0", value: Binding(
                    get: { splitValues[member.id, default: 0] },
                    set: { splitValues[member.id] = $0 }
                ), format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 72)
                .multilineTextAlignment(.trailing)
                Text(expenseCurrency.symbol).foregroundColor(.splitMuted)
            }
        }
    }

    private func loadInitialState() {
        expenseCurrency = group.currency
        paidBy = group.members.first?.id ?? UUID()
        singlePayerId = group.members.first?.id

        switch mode {
        case .add(let template):
            if let template { applyTemplate(template) } else { applySplitType() }
        case .edit(let expense):
            title = expense.title
            amount = expense.amount
            expenseCurrency = expense.currency
            category = expense.category
            paidBy = expense.paidBy
            date = expense.date
            splitType = expense.splitType
            notes = expense.notes ?? ""
            for split in expense.splits {
                if splitType == .percentage, amount > 0 {
                    splitValues[split.memberId] = split.amount / amount * 100
                } else {
                    splitValues[split.memberId] = split.amount
                }
            }
            if splitType == .singlePayer {
                singlePayerId = expense.splits.first { $0.amount > 0 }?.memberId
            }
        }
    }

    private func applyTemplate(_ template: ExpenseTemplate) {
        title = template.title
        category = template.category
        splitType = template.splitType
        if let defaultAmount = template.defaultAmount { amount = defaultAmount }
        applySplitType()
    }

    private func applySplitType() {
        splitValues = SplitCalculator.defaultSplitValues(splitType: splitType, members: group.members, amount: amount)
        if splitType == .singlePayer { singlePayerId = group.members.first?.id }
    }

    private func saveExpense() {
        let computed = SplitCalculator.computeSplits(
            amount: amount, splitType: splitType, members: group.members,
            splitValues: splitValues, singlePayerId: singlePayerId
        )
        let splits = group.members.map { member in
            Split(
                id: editingExpense?.splits.first { $0.memberId == member.id }?.id ?? UUID(),
                memberId: member.id,
                amount: computed[member.id, default: 0],
                isPaid: false
            )
        }

        if saveAsTemplate, editingExpense == nil {
            viewModel.saveAsTemplate(
                title: title.trimmingCharacters(in: .whitespaces),
                category: category, splitType: splitType,
                amount: amount > 0 ? amount : nil
            )
        }

        if let existing = editingExpense {
            viewModel.updateExpense(in: group.id, expense: Expense(
                id: existing.id, title: title.trimmingCharacters(in: .whitespaces),
                amount: amount, currency: expenseCurrency, category: category,
                paidBy: paidBy, date: date, splits: splits, splitType: splitType,
                notes: notes.isEmpty ? nil : notes, receiptImage: existing.receiptImage,
                createdAt: existing.createdAt
            ))
        } else {
            viewModel.addExpense(to: group.id, expense: Expense(
                id: UUID(), title: title.trimmingCharacters(in: .whitespaces),
                amount: amount, currency: expenseCurrency, category: category,
                paidBy: paidBy, date: date, splits: splits, splitType: splitType,
                notes: notes.isEmpty ? nil : notes, receiptImage: nil, createdAt: Date()
            ))
        }
        dismiss()
    }
}
