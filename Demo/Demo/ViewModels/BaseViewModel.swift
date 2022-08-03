import UIKit
import Card
import PayPalWebCheckout
import PaymentsCore
import AuthenticationServices
import PayPalNativeCheckout

/// This class is used to share the orderID across shared views, update the text of `bottomStatusLabel` in our `FeatureBaseViewController`
/// as well as share the logic of `processOrder` across our duplicate (SwiftUI and UIKit) card views.
class BaseViewModel: ObservableObject, PayPalWebCheckoutDelegate, CardDelegate, PayPalDelegate {

    var nativeCheckoutResult: NativeCheckoutResult?
    func paypal(_ payPalClient: PayPalClient, didFinishWithResult result: PayPalResult) {
        nativeCheckoutResult = NativeCheckoutResult.approved(ApprovalResult(
            orderId: result.orderID, payerId: result.payerID
        ))
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
        nativeCheckoutResult = NativeCheckoutResult.error(error)
    }

    func paypalDidCancel(_ payPalClient: PayPalClient) {
        nativeCheckoutResult = NativeCheckoutResult.cancel
    }


    private static var returnUrl: String {
        if let identifier = Bundle.main.bundleIdentifier {
            return "\(identifier)://example.com/returnUrl"
        }
        return ""
    }
    private static var cancelUrl: String {
        if let identifier = Bundle.main.bundleIdentifier {
            return "\(identifier)://example.com/cancelUrl"
        }
        return ""
    }

    /// Weak reference to associated view
    weak var view: FeatureBaseViewController?
    var payPalWebCheckoutClient: PayPalWebCheckoutClient?

    /// order ID shared across views
    @Published var orderID: String?

    // MARK: - Init

    init(view: FeatureBaseViewController? = nil) {
        self.view = view
    }

    // MARK: - Helper Functions

    func updateTitle(_ message: String) {
        DispatchQueue.main.async {
            self.view?.bottomStatusLabel.text = message
        }
    }

    func updateOrderID(with orderID: String) {
        DispatchQueue.main.async {
            self.orderID = orderID
        }
    }

    func createOrder(amount: String?) async -> String? {
        updateTitle("Creating order...")
        guard let amount = amount else { return nil }

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            applicationContext: ApplicationContext(returnUrl: BaseViewModel.returnUrl, cancelUrl: BaseViewModel.cancelUrl)
        )

        do {
            let order = try await DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams)
            updateTitle("Order ID: \(order.id)")
            updateOrderID(with: order.id)
            print("✅ fetched orderID: \(order.id) with status: \(order.status)")
        } catch {
            updateTitle("Your order has failed, please try again")
            print("❌ failed to fetch orderID: \(error)")
        }
        return orderID
    }

    func processOrder(orderID: String) async {
        switch DemoSettings.intent {
        case .authorize:
            updateTitle("Authorizing order...")
        case .capture:
            updateTitle("Capturing order...")
        }

        let processOrderParams = ProcessOrderParams(
            orderId: orderID,
            intent: DemoSettings.intent.rawValue,
            countryCode: "US"
        )

        do {
            let order = try await DemoMerchantAPI.sharedService.processOrder(processOrderParams: processOrderParams)
            updateTitle("\(DemoSettings.intent.rawValue.capitalized) success: \(order.status)")
            print("✅ processed orderID: \(order.id) with status: \(order.status)")
        } catch {
            updateTitle("\(DemoSettings.intent.rawValue.capitalized) fail: \(error.localizedDescription)")
            print("❌ failed to process orderID: \(error)")
        }
    }

    // MARK: Card Module Integration

    func createCard(cardNumber: String?, expirationDate: String?, cvv: String?) -> Card? {
        guard let cardNumber = cardNumber, let expirationDate = expirationDate, let cvv = cvv else {
            updateTitle("Failed: missing card / orderID.")
            return nil
        }

        let cleanedCardText = cardNumber.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDate.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return Card(number: cleanedCardText, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvv)
    }

    func checkoutWith(
        card: Card,
        orderID: String,
        context: ASWebAuthenticationPresentationContextProviding
    ) async {
        guard let config = await getCoreConfig() else {
            return
        }
        let cardClient = CardClient(config: config)
        cardClient.delegate = self
        let cardRequest = CardRequest(orderID: orderID, card: card, threeDSecureRequest: createThreeDSecureRequest())
        cardClient.approveOrder(request: cardRequest, context: context)
    }

    func checkoutWithNativeClient(orderId: String?) async throws -> NativeCheckoutResult {
        guard let orderId = orderId else {

            return NativeCheckoutResult.error(CoreSDKError(code: 0, domain: "Order Id is null", errorDescription: "Order Id is null"))
        }
        let nativeCheckoutClient = try await getNativeCheckoutClient()
        let paypalRequest = PayPalRequest(orderID: orderId)
        nativeCheckoutClient.delegate = self
        DispatchQueue.main.async {
            nativeCheckoutClient.start(request: paypalRequest)
        }
        guard let nativeCheckoutResult = nativeCheckoutResult
        else {
            throw CoreSDKError(code: 0, domain: "checkout", errorDescription: "didn't get result from checkout")
        }
        return nativeCheckoutResult
    }

    func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        guard orderID != nil else {
            updateTitle("Create an order to proceed")
            return false
        }

        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }

    private func createThreeDSecureRequest() -> ThreeDSecureRequest {
        ThreeDSecureRequest(
            sca: .scaAlways,
            returnUrl: BaseViewModel.returnUrl,
            cancelUrl: BaseViewModel.cancelUrl
        )
    }

    // MARK: - PayPal Module Integration

    func payPalCreditButtonTapped(context: ASWebAuthenticationPresentationContextProviding) {
        paymentButtonTapped(context: context, funding: .paypalCredit)
    }

    func payPalButtonTapped(context: ASWebAuthenticationPresentationContextProviding) {
        paymentButtonTapped(context: context, funding: .paypal)
    }

    private func paymentButtonTapped(
        context: ASWebAuthenticationPresentationContextProviding,
        funding: PayPalWebCheckoutFundingSource
    ) {
        guard let orderID = orderID else {
            self.updateTitle("Failed: missing orderID.")
            return
        }

        checkoutWithPayPal(orderID: orderID, context: context, funding: funding)
    }
    func checkoutWithPayPal(
        orderID: String,
        context: ASWebAuthenticationPresentationContextProviding,
        funding: PayPalWebCheckoutFundingSource
    ) {
        Task {
            do {
                payPalWebCheckoutClient = try await getPayPalClient()
                guard let client = payPalWebCheckoutClient else {
                    print("Error in initializing paypal webcheckout client")
                    return
                }
                let payPalRequest = PayPalWebCheckoutRequest(orderID: orderID, fundingSource: funding)
                client.start(request: payPalRequest, context: context)
            } catch {
                print("Error in starting paypal webcheckout client")
            }
        }
    }

    // MARK: - PayPal Delegate

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult) {
        updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: CONFIRMED")
        print("✅ Order is successfully approved and ready to be captured/authorized with result: \(result)")
    }

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
        print("❌ There was an error: \(error)")
    }

    func payPalDidCancel(_ payPalClient: PayPalWebCheckoutClient) {
        updateTitle("\(DemoSettings.intent) cancelled")
        print("❌ Buyer has cancelled the PayPal flow")
    }

    // TODO: this is just for test, need to be removed after final integration
    func testEligibility() async throws {
        guard let config = await getCoreConfig() else {
            print("error in making config for test eligibility")
            return
        }
        let eligibilityAPI = EligibilityAPI(coreConfig: config)
        do {
            let eligibility = try await eligibilityAPI.checkEligibility()
            print(eligibility)
        } catch {
            print("error in test eligibility")
        }
    }
    // MARK: - Card Delegate

    func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
        updateTitle("Order Id:\(result.orderID) status: \(result.status)\n \(String(describing: result.paymentSource))")
    }

    func card(_ cardClient: CardClient, didFinishWithError error: CoreSDKError) {
        updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
        print("❌ There was an error: \(error)")
    }

    func cardDidCancel(_ cardClient: CardClient) {
        updateTitle("\(DemoSettings.intent) cancelled")
        print("❌ Buyer has cancelled the Card flow")
    }

    func cardThreeDSecureWillLaunch(_ cardClient: CardClient) {
        updateTitle("3DS challenge will be launched")
        print("3DS challenge will be launched")
    }

    func cardThreeDSecureDidFinish(_ cardClient: CardClient) {
        updateTitle("3DS challenge has finished")
        print("3DS challenge has finished")
    }

    func getAccessToken() async -> String? {
        await DemoMerchantAPI.sharedService.getAccessToken(environment: DemoSettings.environment)
    }

    func getCoreConfig() async -> CoreConfig? {
        guard let token = await getAccessToken() else {
            return nil
        }
        return CoreConfig(clientID: DemoSettings.clientID, accessToken: token, environment: DemoSettings.environment.paypalSDKEnvironment)
    }

    func getNativeCheckoutClient() async throws -> PayPalClient {
        guard let config = await getCoreConfig() else {
            throw CoreSDKError(code: 0, domain: "Error initializing paypal webcheckout client", errorDescription: nil)
        }
        return PayPalClient(config: config)
    }

    func getPayPalClient() async throws -> PayPalWebCheckoutClient {
        guard let config = await getCoreConfig() else {
            throw CoreSDKError(code: 0, domain: "Error initializing paypal webcheckout client", errorDescription: nil)
        }
        let payPalClient = PayPalWebCheckoutClient(config: config)
        return payPalClient
    }
}
