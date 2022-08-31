import UIKit
import PayPalCheckout
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal Paysheet to handle PayPal transaction
/// encapsulates instance to communicate with nxo
public class PayPalClient {

    public weak var delegate: PayPalDelegate?
    private let nativeCheckoutProvider: NativeCheckoutStartable
    private let apiClient: APIClient
    private let config: CoreConfig

    /// Initialize a PayPalClient to process PayPal transaction
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
    ///   - delegate: Completion block to handle buyer's approval, cancellation, error, create order callback, shipping change callback
    public func start(presentingViewController: UIViewController? = nil, orderID: String, delegate: PayPalDelegate?) async {
        do {
            let clientID = try await apiClient.getClientID()
            let nxoConfig = CheckoutConfig(
                clientID: clientID,
                createOrder: nil,
                onApprove: nil,
                onShippingChange: nil,
                onCancel: nil,
                onError: nil,
                environment: config.environment.toNativeCheckoutSDKEnvironment()
            )
            self.delegate = delegate
            self.nativeCheckoutProvider.start(
                presentingViewController: presentingViewController,
                createOrder: { order in
                    order.set(orderId: orderID)
                },
                onApprove: { approval in
                    self.notifySuccess(for: approval)
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
            delegate?.paypal(self, didFinishWithError: PayPalError.clientIDNotFoundError(error))
        }
    }

    private func notifySuccess(for approval: PayPalCheckout.Approval) {
        delegate?.paypal(self, didFinishWithResult: approval)
    }

    private func notifyFailure(with errorInfo: PayPalCheckoutErrorInfo) {
        let error = PayPalError.nativeCheckoutSDKError(errorInfo)
        delegate?.paypal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        delegate?.paypalDidCancel(self)
    }

    private func notifyShippingChange(shippingChange: ShippingChange, shippingChangeAction: ShippingChangeAction) {
        delegate?.paypalDidShippingAddressChange(self, shippingChange: shippingChange, shippingChangeAction: shippingChangeAction)
    }
}
