import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

/// PayPal Paysheet to handle PayPal transaction
/// encapsulates instance to communicate with nxo
public class PayPalNativeCheckoutClient {

    public weak var delegate: PayPalNativeCheckoutDelegate?
    public weak var shippingDelegate: PayPalNativeShippingDelegate?
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
                    switch shippingChange.type {
                    case .shippingAddress:
                        shippingChangeAction.approve()
                        let shippingAddress = PayPalNativeShippingAddress(shippingChange.selectedShippingAddress)
                        self.notifyShippingChange(shippingAddress: shippingAddress)
                        
                    case .shippingMethod:
                        guard let selectedShippingMethod = shippingChange.selectedShippingMethod else {
                            return
                        }
                        
                        Task {
                            await self.patchShippingMethodChanges(
                                orderID: request.orderID,
                                selectedShippingMethod: selectedShippingMethod,
                                shippingChange: shippingChange,
                                shippingChangeAction: shippingChangeAction
                            )
                        }
                    @unknown default:
                        break // do nothing
                    }
                },
                onCancel: {
                    self.notifyCancellation()
                },
                onError: { error in
                    self.notifyFailure(with: error.reason)
                },
                nxoConfig: nxoConfig
            )
        } catch {
            delegate?.paypal(self, didFinishWithError: CorePaymentsError.clientIDNotFoundError)
        }
    }
    
    /// Updates the underlying orderID to include the newly selected shipping amount price.
    ///
    /// https://developer.paypal.com/docs/api/orders/v2/#orders_patch
    func patchShippingMethodChanges(
        orderID: String,
        selectedShippingMethod: ShippingMethod,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) async {
        guard let shippingPriceString = selectedShippingMethod.amount?.value,
              let currencyCode = selectedShippingMethod.amount?.currencyCode,
              let shippingPrice = Decimal(string: shippingPriceString) else {
            // error, missing amount details on newly selected shipping method
            return
        }
        
        guard let existingOrderPriceString = try? await self.getOrderAmount(for: orderID),
              let existingOrderPrice = Decimal(string: existingOrderPriceString) else {
            // error
            return
        }
        
        let newPurchaseUnit = PayPalCheckout.PurchaseUnit.Amount(
            currencyCode: currencyCode,
            value: String(describing: existingOrderPrice + shippingPrice)
        )
        
        let patchRequest = PayPalCheckout.PatchRequest()
        patchRequest.add(shippingOptions: shippingChange.shippingMethods)
        patchRequest.replace(amount: newPurchaseUnit)
        
        shippingChangeAction.patch(request: patchRequest) { _, error in
            if let error {
                self.notifyFailure(with: error.localizedDescription)
            } else {
                let shippingMethod = PayPalNativeShippingMethod(selectedShippingMethod)
                self.notifyShippingMethod(shippingMethod: shippingMethod)
            }
        }
    }
    
    /// Fetches the current amount details associated with the orderID
    private func getOrderAmount(for orderID: String) async throws -> String {
        let request = GetOrderAmountRequest(orderID: orderID, accessToken: config.accessToken)
        let orderAmountResponse = try await apiClient.fetch(request: request)
        if let amount = orderAmountResponse.purchaseUnits?.first?.amount.value {
            return amount
        } else {
            throw PayPalNativePaymentsError.getOrderDetailsError(orderID)
        }
    }
    
    private func notifySuccess(for result: PayPalNativeCheckoutResult) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:succeeded")
        delegate?.paypal(self, didFinishWithResult: result)
    }

    private func notifyFailure(with errorDescription: String) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:failed")
        
        let error = PayPalNativePaymentsError.nativeCheckoutSDKError(errorDescription)
        delegate?.paypal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        apiClient.sendAnalyticsEvent("paypal-native-payments:canceled")
        delegate?.paypalDidCancel(self)
    }
    
    private func notifyShippingMethod(shippingMethod: PayPalNativeShippingMethod) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:shipping-method-changed")
        shippingDelegate?.paypal(self, didShippingMethodChange: shippingMethod)
    }
    
    private func notifyShippingChange(shippingAddress: PayPalNativeShippingAddress) {
        apiClient.sendAnalyticsEvent("paypal-native-payments:shipping-address-changed")
        shippingDelegate?.paypal(self, didShippingAddressChange: shippingAddress)
    }
}
