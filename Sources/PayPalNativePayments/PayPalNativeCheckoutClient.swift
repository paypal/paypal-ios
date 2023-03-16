import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

/// PayPal Paysheet to handle PayPal transaction
/// encapsulates instance to communicate with nxo
public class PayPalNativeCheckoutClient {

    public weak var delegate: PayPalNativeCheckoutDelegate?
    private let nativeCheckoutProvider: NativeCheckoutStartable
    private let apiClient: APIClient
    private let config: CoreConfig

    /// Initialize a PayPalNativeCheckoutClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    public convenience init(config: CoreConfig) {
        self.init(
            config: config,
            nativeCheckoutProvider: NativeCheckoutProvider(),
            apiClient: APIClient(coreConfig: config)
        )
    }

    init(config: CoreConfig, nativeCheckoutProvider: NativeCheckoutStartable, apiClient: APIClient) {
        self.config = config
        self.nativeCheckoutProvider = nativeCheckoutProvider
        self.apiClient = apiClient
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    ///   - createOrder: action to perform when an order has been created
    public func start(
        presentingViewController: UIViewController? = nil,
        createOrder: @escaping PayPalCheckout.CheckoutConfig.CreateOrderCallback
    ) async {
        do {
            let clientID = try await apiClient.fetchCachedOrRemoteClientID()
            let nxoConfig = CheckoutConfig(
                clientID: clientID,
                createOrder: nil,
                onApprove: nil,
                onShippingChange: nil,
                onCancel: nil,
                onError: nil,
                environment: config.environment.toNativeCheckoutSDKEnvironment()
            )
            delegate?.paypalWillStart(self)
            
            apiClient.sendAnalyticsEvent("paypal-native-payments:started")
            self.nativeCheckoutProvider.start(
                presentingViewController: presentingViewController,
                createOrder: createOrder,
                onApprove: { approval in
                    let result = PayPalNativeCheckoutResult(
                        orderID: approval.data.ecToken,
                        payerID: approval.data.payerID
                    )
                    self.notifySuccess(for: result)
                },
                onShippingChange: { shippingChange, shippingChangeAction in
                    self.notifyShippingChange(shippingChange: shippingChange, shippingChangeAction: shippingChangeAction)
                },
                onCancel: {
                    self.notifyCancellation()
                },
                onError: { error in
                    self.notifyFailure(with: error)
                },
                nxoConfig: nxoConfig
            )
        } catch {
            delegate?.paypal(self, didFinishWithError: CorePaymentsError.clientIDNotFoundError)
        }
    }

    private func notifySuccess(for result: PayPalNativeCheckoutResult) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:succeeded")
        delegate?.paypal(self, didFinishWithResult: result)
    }

    private func notifyFailure(with errorInfo: PayPalCheckout.ErrorInfo) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:failed")
        
        let error = PayPalNativePaymentsError.nativeCheckoutSDKError(errorInfo.reason)
        delegate?.paypal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        apiClient.sendAnalyticsEvent("paypal-native-payments:canceled")
        delegate?.paypalDidCancel(self)
    }

    private func notifyShippingChange(shippingChange: ShippingChange, shippingChangeAction: ShippingChangeAction) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:shipping-address-changed")
        delegate?.paypalDidShippingAddressChange(self, shippingChange: shippingChange, shippingChangeAction: shippingChangeAction)
    }
}