import ApplePay
import CorePayments
import PassKit
import SwiftUI

@MainActor
final class ApplePayDemoViewModel: ObservableObject {

    @Published var merchantIdentifier = ""
    @Published var amount = "10.00"
    @Published var message: String?
    @Published var isProcessing = false

    private let configManager = CoreConfigManager(domain: "Apple Pay")

    func pay() async {
        guard !merchantIdentifier.isEmpty else {
            message = "Enter the Apple merchant ID from the app's Apple Pay entitlement."
            return
        }

        isProcessing = true
        message = nil
        defer { isProcessing = false }

        do {
            let order = try await createOrder()
            let result = try await ApplePayClient(config: configManager.getCoreConfig()).approveOrder(
                request: ApplePayRequest(
                    orderID: order.id,
                    merchantIdentifier: merchantIdentifier,
                    currencyCode: "USD",
                    total: ApplePaySummaryItem(label: "Demo", amount: Decimal(string: amount) ?? 10)
                )
            )
            message = "Approved \(result.orderID) (\(result.status)). Capture the order on your server."
        } catch {
            message = error.localizedDescription
        }
    }

    private func createOrder() async throws -> Order {
        let params = CreateOrderParams(
            intent: "CAPTURE",
            purchaseUnits: [PurchaseUnit(amount: Amount(currencyCode: "USD", value: amount))],
            paymentSource: nil
        )
        return try await DemoMerchantAPI.shared.createOrder(
            orderParams: params,
            integration: DemoSettings.merchantIntegration
        )
    }
}

struct ApplePayDemoView: View {

    @StateObject private var model = ApplePayDemoViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sandbox uses the environment selected on the previous screen. Apple Pay stays in this app.")
                .font(.footnote)
            TextField("merchant.com.example", text: $model.merchantIdentifier)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            TextField("Amount", text: $model.amount)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            if model.isProcessing {
                ProgressView()
            } else {
                PayWithApplePayButton(.buy) {
                    Task { await model.pay() }
                }
                .frame(height: 44)
                .opacity(model.merchantIdentifier.isEmpty ? 0.4 : 1)
            }
            if let message = model.message {
                Text(message)
                    .font(.footnote)
            }
            Spacer()
        }
        .padding()
    }
}
