import SwiftUI

struct TemplatesManageView: View {
    @ObservedObject var viewModel: SplitWiseViewModel

    var body: some View {
        ScrollView {
            if viewModel.expenseTemplates.isEmpty {
                EmptyStateView(
                    icon: "doc.on.doc.fill",
                    title: "No templates",
                    message: "When adding an expense, enable Save as template to create quick shortcuts."
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.expenseTemplates) { template in
                        templateCell(template)
                    }
                }
                .padding(20)
            }
        }
        .splitScreenBackground()
        .navigationTitle("Templates")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func templateCell(_ template: ExpenseTemplate) -> some View {
        HStack(spacing: 14) {
            IconBadgeView(systemName: template.category.icon, color: .splitCredit, size: 48)

            VStack(alignment: .leading, spacing: 6) {
                Text(template.title)
                    .font(.headline)
                    .foregroundColor(.black)
                HStack(spacing: 8) {
                    StatusBadge(text: template.category.rawValue, tone: .neutral)
                    StatusBadge(text: template.splitType.shortLabel, tone: .credit)
                }
                if let amount = template.defaultAmount {
                    Text(formatCurrency(amount))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.splitCredit)
                }
            }

            Spacer()

            Button {
                viewModel.deleteTemplate(template)
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.splitDebt.opacity(0.8))
            }
        }
        .padding(14)
        .splitCardStyle(cornerRadius: 14, elevation: .low)
    }
}
