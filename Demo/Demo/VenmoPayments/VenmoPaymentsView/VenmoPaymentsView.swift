import SwiftUI

struct VenmoPaymentsView: View {

    @StateObject var venmoViewModel = VenmoViewModel()

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {

                    VenmoCreateOrderView(venmoViewModel: venmoViewModel)

                    if case .loaded = venmoViewModel.state.createdOrderResponse {
                        VenmoApproveOrderView(venmoViewModel: venmoViewModel)
                    }

                    if case .loaded = venmoViewModel.state.approveResultResponse {
                        VenmoApprovalResultView(venmoViewModel: venmoViewModel)

                        VenmoCaptureOrderView(venmoViewModel: venmoViewModel)
                    }

                    if case .loaded = venmoViewModel.state.capturedOrderResponse {
                        VenmoCaptureResultView(venmoViewModel: venmoViewModel)
                    }

                    Text("")
                        .id("bottomView")
                }
                .onChange(of: venmoViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}

// MARK: - Create Order View

struct VenmoCreateOrderView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create an Order")
                    .font(.system(size: 20))
                Spacer()
                Button("Reset") {
                    venmoViewModel.resetState()
                }
            }
            .frame(maxWidth: .infinity)
            .font(.headline)

            ZStack {
                Button("Create an Order") {
                    Task {
                        await venmoViewModel.createOrder()
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())

                if case .loading = venmoViewModel.state.createdOrderResponse {
                    CircularProgressView()
                }
            }

            if case .error(let message) = venmoViewModel.state.createdOrderResponse {
                ErrorView(errorMessage: message)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}

// MARK: - Approve Order View

struct VenmoApproveOrderView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack(spacing: 16) {
            if let order = venmoViewModel.state.createOrder {
                LabelViewText(label: "Order ID", text: order.id)
                LabelViewText(label: "Status", text: order.status)
            }

            ZStack {
                Button("Pay with Venmo") {
                    venmoViewModel.venmoButtonTapped()
                }
                .buttonStyle(RoundedBlueButtonStyle())

                if case .loading = venmoViewModel.state.approveResultResponse {
                    CircularProgressView()
                }
            }

            if case .error(let message) = venmoViewModel.state.approveResultResponse {
                ErrorView(errorMessage: message)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}

// MARK: - Approval Result View

struct VenmoApprovalResultView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Venmo Approval")
                .font(.system(size: 20, weight: .semibold))

            if let result = venmoViewModel.checkoutResult {
                LabelViewText(label: "Order ID", text: result.orderID)
                LabelViewText(label: "Payer ID", text: result.payerID)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}

// MARK: - Capture Order View

struct VenmoCaptureOrderView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Button("Capture Order") {
                    Task {
                        await venmoViewModel.completeTransaction()
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())

                if case .loading = venmoViewModel.state.capturedOrderResponse {
                    CircularProgressView()
                }
            }

            if case .error(let message) = venmoViewModel.state.capturedOrderResponse {
                ErrorView(errorMessage: message)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}

// MARK: - Capture Result View

struct VenmoCaptureResultView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Order Captured")
                .font(.system(size: 20, weight: .semibold))

            if let order = venmoViewModel.state.capturedOrder {
                LabelViewText(label: "Order ID", text: order.id)
                LabelViewText(label: "Status", text: order.status)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
