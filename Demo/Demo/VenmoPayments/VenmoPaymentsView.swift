import SwiftUI

struct VenmoPaymentsView: View {

    @StateObject private var viewModel = VenmoViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VenmoCheckoutCard(viewModel: viewModel)
                createdOrderSection
                approvalSection
                completionSection
            }
            .padding(.bottom, 20)
        }
        .onOpenURL { url in
            viewModel.handleReturnURL(url)
        }
    }

    @ViewBuilder private var createdOrderSection: some View {
        switch viewModel.state.createdOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .error(let message):
            ErrorView(errorMessage: message)
        case .loaded(let order):
            card {
                Text("Order Details").font(.system(size: 20))
                LabelViewText("Order ID:", bodyText: order.id)
                LabelViewText("Status:", bodyText: order.status)
            }
        }
    }

    @ViewBuilder private var approvalSection: some View {
        switch viewModel.state.approveResultResponse {
        case .idle, .loading:
            EmptyView()
        case .error(let message):
            ErrorView(errorMessage: message)
        case .loaded(let result):
            card {
                Text("Approval Result").font(.headline)
                LabelViewText("Order ID:", bodyText: result.id)
                LabelViewText("Payer ID:", bodyText: result.payerID)
            }
            ZStack {
                Button("\(viewModel.intent.rawValue.capitalized) Order") {
                    Task { await viewModel.completeTransaction() }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()
                if case .loading = viewModel.state.completedOrderResponse {
                    CircularProgressView()
                }
            }
        }
    }

    @ViewBuilder private var completionSection: some View {
        switch viewModel.state.completedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .error(let message):
            ErrorView(errorMessage: message)
        case .loaded(let order):
            card {
                Text("Order \(viewModel.intent == .authorize ? "Authorized" : "Captured") Successfully")
                    .font(.system(size: 20))
                LabelViewText("Order ID:", bodyText: order.id)
                LabelViewText("Status:", bodyText: order.status)
            }
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) { content() }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 2).padding(5))
    }
}

private struct VenmoCheckoutCard: View {

    @ObservedObject var viewModel: VenmoViewModel
    @State private var selectedIntent: Intent = .authorize
    @State private var amount = "10.00"

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Checkout")
                    .font(.system(size: 20))
                Spacer()
                Button("Reset") { viewModel.resetState() }
            }
            .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Intent").font(.subheadline)
                Picker("Intent", selection: $selectedIntent) {
                    ForEach(Intent.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            FloatingLabelTextField(placeholder: "Amount", text: $amount, keyboardType: .decimalPad)

            ZStack {
                Button("Pay with Venmo") {
                    viewModel.intent = selectedIntent
                    Task { await viewModel.checkout(amount: amount) }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = viewModel.state.createdOrderResponse {
                    CircularProgressView()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 2).padding(5))
    }
}
