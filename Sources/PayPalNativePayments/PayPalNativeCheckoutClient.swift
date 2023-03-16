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
    
    private var shippingChangeAction: ShippingChangeAction?
    private var shippingChange: ShippingChange?
    
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
    ///   - request: The PayPalNativeCheckoutRequest for the transaction
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    public func start(
        request: PayPalNativeCheckoutRequest,
        presentingViewController: UIViewController? = nil
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
                createOrder: { orderRequestAction in
                    orderRequestAction.set(orderId: request.orderID)
                },
                onApprove: { approval in
                    let result = PayPalNativeCheckoutResult(
                        orderID: approval.data.ecToken,
                        payerID: approval.data.payerID
                    )
                    self.notifySuccess(for: result)
                },
                onShippingChange: { shippingChange, shippingChangeAction in
                    self.shippingChangeAction = shippingChangeAction
                    // sample merchant response actions - shippingChangeAction.reject(), patch(), approve()
                    // TODO: - Determine how we want merchant to respond to shippingChange with these actions.
                    // shippingChangeAction.reject()
                    
                    switch shippingChange.type {
                    case .shippingAddress:
                        // Transform shippingChange --> shippingAddress
                        let shippingAddress = PayPalNativeShippingAddress(
                            addressID: shippingChange.selectedShippingAddress.addressID,
                            fullName: shippingChange.selectedShippingAddress.fullName,
                            adminArea1: shippingChange.selectedShippingAddress.adminArea1,
                            adminArea2: shippingChange.selectedShippingAddress.adminArea2,
                            adminArea3: shippingChange.selectedShippingAddress.adminArea3,
                            adminArea4: shippingChange.selectedShippingAddress.adminArea4,
                            postalCode: shippingChange.selectedShippingAddress.postalCode,
                            countryCode: shippingChange.selectedShippingAddress.countryCode
                        )
                        self.notifyShippingChange2(shippingAddress: shippingAddress)
                        
                    case .shippingMethod:
                        // Transform shippingChange --> shippingMethod
                        let nxoShippingList = shippingChange.shippingMethods.map { method in
                            PayPalNativePayments.PayPalNativeShippingMethod(
                                id: method.id,
                                label: method.label,
                                selected: method.selected,
                                type: method.type == .pickup ? PayPalNativePayments.ShippingType.pickup : PayPalNativePayments.ShippingType.shipping,
                                value: method.amount?.value,
                                currencyCodeString: method.amount?.currencyCodeString
                            )
                        }
                                                
                        self.delegate?.onShippingMethodChanged(self, shippingMethods: nxoShippingList)
                    @unknown default:
                        // do nothing
                        print("")
                    }

                    // existing code
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
    
    func replaceAmount(_ amount: String) {
        if (amount != shippingChange?.selectedShippingMethod?.amount?.value) {
            // shippingChangeAction.patch(amount)
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
    
    private func notifyShippingMethod(shippingMethods: [PayPalNativeShippingMethod]) {
        delegate?.onShippingMethodChanged(self, shippingMethods: shippingMethods)
    }
    
    private func notifyShippingChange2(shippingAddress: PayPalNativeShippingAddress) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:shipping-address-changed")
        delegate?.onShippingAddressChanged(self, shippingAddress: shippingAddress)
    }

    private func notifyShippingChange(shippingChange: ShippingChange, shippingChangeAction: ShippingChangeAction) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:shipping-address-changed")
        delegate?.paypalDidShippingAddressChange(self, shippingChange: shippingChange, shippingChangeAction: shippingChangeAction)
    }
}
