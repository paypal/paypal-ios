import UIKit
import PayPalNativeCheckout
import PayPalCheckout
import PaymentsCore
import Card

class PayPalViewModel: ObservableObject, PayPalDelegate {

    enum State {
        case initial
        case loading(content: String)
        case mainContent(title: String, content: String, flowComplete: Bool)
    }

    @Published private(set) var state = State.initial

    private var accessToken = ""
    private var payPalClient: PayPalClient?

    func getAccessToken() {
        Task {
            state = .loading(content: "Getting access token")
            guard let token = await getAccessToken() else {
                state = .mainContent(title: "Error", content: "Failed to fetch access token", flowComplete: true)

                return
            }
            accessToken = token
            payPalClient = PayPalClient(config: CoreConfig(accessToken: token, environment: PaymentsCore.Environment.sandbox))
            payPalClient?.delegate = self
            state = .mainContent(title: "Access Token", content: accessToken, flowComplete: false)
        }
    }

    func retry() {
        payPalClient = nil
        accessToken = ""
        state = .initial
    }

    func checkoutWithOrder() {
        startNativeCheckout {
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.create(order: self.createOrderRequest())
            }
        }
    }

    func checkoutWithOrderID() {
        startNativeCheckout {
            let orderID = try await self.getOrderIDWithFixedShipping()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(orderId: orderID)
            }
        }
    }

    func checkoutWithBillingAgreement() {
        startNativeCheckout {
            let order = try await self.getBillingAgreementToken()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(billingAgreementToken: order.id)
            }
        }
    }

    func checkoutBAWithoutPurchase() {
        startNativeCheckout {
            let billingAgreementToken = try await self.getBillingAgreementTokenWithoutPurchase(
                accessToken: self.accessToken)
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(billingAgreementToken: billingAgreementToken)
            }
        }
    }

    func checkoutWithVault() {
        startNativeCheckout {
            guard let vaultSessionID = try await self.getApprovalSessionID() else {
                self.state = .mainContent(
                    title: "Error",
                    content: "Error in creating vault session!!",
                    flowComplete: true
                )

                return
            }
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(vaultApprovalSessionID: vaultSessionID)
            }
        }
    }

    private func startNativeCheckout(withAction action: @escaping () async throws -> Void) {
        state = .loading(content: "Initializing checkout")
        Task {
            do {
                try await action()
            } catch let error {
                self.state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
            }
        }
    }

    func getAccessToken() async -> String? {
        await DemoMerchantAPI.sharedService.getAccessToken(environment: DemoSettings.environment)
    }

    func getOrderIDWithFixedShipping() async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(orderParams: requestWithFixedShipping)
        return order.id
    }

    func getBillingAgreementToken() async throws -> Order {
        return try await DemoMerchantAPI.sharedService.createOrder(orderParams: billingAgreementTokenRequest)
    }

    func getBillingAgreementTokenWithoutPurchase(accessToken: String) async throws -> String {
        let baToken = try await DemoMerchantAPI.sharedService.createBillingAgreementToken(
            accessToken: accessToken,
            billingAgremeentTokenRequest: billingAgreementWithoutPaymentRequest
        )
        return baToken.tokenID
    }

    func getApprovalSessionID() async throws -> String? {
        let vaultSessionID = try await DemoMerchantAPI.sharedService.createApprovalSessionID(
            accessToken: self.accessToken,
            approvalSessionRequest: approvalSessionRequest
        )

        let approvalSessionIDLink = vaultSessionID.links.first { $0.rel == "approve" }
        if let hrefLink = approvalSessionIDLink?.href {
            return URLComponents(string: hrefLink)?.queryItems?.first { $0.name == "approval_session_id" }?.value
        }
        return nil
    }

    // MARK: - hardcoded order request

    private let requestWithFixedShipping = CreateOrderParams(
        intent: "AUTHORIZE",
        purchaseUnits: [
            PurchaseUnit(
                amount: Amount(
                    currencyCode: "USD",
                    value: "100.0",
                    breakdown: Breakdown(
                        discount: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        handling: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        itemTotal: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        shipping: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        shippingDiscount: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        taxTotal: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        )
                    )
                ),
                customId: "CUST-HighFashions",
                description: "Sporting Goods",
                items: [
                    Item(
                        category: "PHYSICAL_GOODS",
                        description: "Running, Size 10.5",
                        name: "T-Shirt",
                        quantity: "2",
                        sku: "sku2",
                        tax: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        unitAmount: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        )
                    ),
                    Item(
                        category: "PHYSICAL_GOODS",
                        description: "Green XL",
                        name: "Shoes",
                        quantity: "1",
                        sku: "sku01",
                        tax: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        unitAmount: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        )
                    )
                ],
                payee: Payee(
                    emailAddress: "merchant@email.com",
                    merchantId: "X5XAHHCG636FA"
                ),
                referenceId: "PUHF",
                shipping: Shipping(
                    address: Address(
                        addressLine1: "123 Townsend St",
                        addressLine2: "Floor 6",
                        locality: "San Francisco",
                        region: "CA",
                        postalCode: "94107",
                        countryCode: "US"
                    )
                ),
                softDescriptor: "HighFashions"
            )
        ],
        applicationContext: ApplicationContext(
            returnUrl: "https://example.com/return",
            cancelUrl: "https://example.com/cancel",
            locale: "de-DE",
            shippingPreference: "SET_PROVIDED_ADDRESS",
            userAction: "PAY_NOW",
            landingPage: "BILLING"
        )
    )

    private let billingAgreementTokenRequest = CreateOrderParams(
        intent: "CAPTURE",
        purchaseUnits: [
            PurchaseUnit(
                amount: Amount(
                    currencyCode: "USD",
                    value: "95.00"
                )
            )
        ],
        paymentSource: PaymentSource(
            paypal: PayPalPaymentSource(
                attributes: Attributes(
                    vault: Vault(
                        confirmPaymentToken: "ON_ORDER_COMPLETION",
                        usageType: "MERCHANT"
                    )
                )
            )
        ),
        applicationContext: ApplicationContext(
            returnUrl: "https://example.com/returnUrl",
            cancelUrl: "https://example.com/cancelUrl",
            shippingPreference: "NO_SHIPPING"
        )
    )

    private let billingAgreementWithoutPaymentRequest = BillingAgreementWithoutPurchaseRequest(
        descrption: "Billing Agreement",
        shippingAddress: ShippingAddress(
            line1: "1350 North First Street",
            city: "San Jose",
            state: "CA",
            postalCode: "95112",
            countryCode: "US",
            recipientName: "John Doe"
        ),
        payer: Payer(
            paymentMethod: "PAYPAL"
        ),
        plan: Plan(
            type: "MERCHANT_INITIATED_BILLING",
            merchantPreferences: MerchantPreferences(
                returnUrl: "https://example.com/return",
                cancelUrl: "https://example.com/cancel",
                notifyUrl: "https://example.com/notify",
                acceptedPymtType: "INSTANT",
                skipShippingAddress: false,
                immutableShippingAddress: true
            )
        )
    )

    private func createOrderRequest(
        amountValue: String = "0.01",
        shippingPreference: OrderApplicationContext.ShippingPreference = .getFromFile,
        userAction: OrderApplicationContext.UserAction = .continue,
        currency: CurrencyCode = .usd,
        orderIntent: OrderIntent = .capture,
        processingInstruction: ProcessingInstruction? = nil
    ) -> OrderRequest {

        let address = OrderAddress(
            countryCode: "US",
            addressLine1: "345 Sesame Street",
            addressLine2: "Apt 9",
            adminArea1: "NY",
            adminArea2: "New York City",
            postalCode: "32422"
        )

        let context = OrderApplicationContext(
            brandName: "Example Inc",
            locale: "de-DE",
            shippingPreference: shippingPreference,
            userAction: userAction,
            paymentMethod: nil,
            returnUrl: "https://example.com/return",
            cancelUrl: "https://example.com/cancel",
            storedPaymentSource: nil
        )

        return OrderRequest(
            intent: orderIntent,
            purchaseUnits: [
                PayPalCheckout.PurchaseUnit(
                    amount: PayPalCheckout.PurchaseUnit.Amount(currencyCode: currency, value: amountValue),
                    shipping: PayPalCheckout.PurchaseUnit.Shipping(
                        shippingName: PayPalCheckout.PurchaseUnit.ShippingName(fullName: "Cookie Monster"),
                        address: address,
                        options: buildShippingMethods(
                            currency: currency,
                            pref: shippingPreference
                        )
                    )
                )
            ],
            processingInstruction: processingInstruction ?? .none,
            payer: nil,
            applicationContext: context
        )
    }

    private func buildShippingMethods(
        currency: CurrencyCode,
        pref: OrderApplicationContext.ShippingPreference
    ) -> [ShippingMethod]? {
        guard pref == .getFromFile  else {
            return nil
        }

        let ship1 = ShippingMethod(
            id: "ShipTest1",
            label: "standard shipping",
            selected: true,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: "3.99")
        )

        let ship2 = ShippingMethod(
            id: "ShipTest2",
            label: "cheap shipping",
            selected: false,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: "0.99")
        )

        let ship3 = ShippingMethod(
            id: "ShipTest3",
            label: "express shipping",
            selected: false,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: "7.99")
        )

        let pick1 = ShippingMethod(
            id: "PickTest1",
            label: "please pick it up from store",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )

        let pick2 = ShippingMethod(
            id: "PickTest2",
            label: "pick it up from warehouse",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )

        let pick3 = ShippingMethod(
            id: "PickTest3",
            label: "pick it from HQ",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )

        return [ship1, ship2, ship3, pick1, pick2, pick3]
    }

    private let approvalSessionRequest = ApprovalSessionRequest(
        customerId: "abcd1234",
        source: Source(
            paypal: PayPalSource(
                usageType: "MERCHANT",
                customerType: "CONSUMER"
            )
        ),
        applicationContext: ApplicationContext(
            returnUrl: "https://example.com",
            cancelUrl: "https://example.com",
            locale: "en-US",
            paymentMethodPreference: PaymentMethodPreference(
                payePreferred: "IMMEDIATE_PAYMENT_REQUIRED",
                payerSelected: "PAYPAL"
            )
        )
    )

    // MARK: - PayPalDelegate conformance

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: Approval) {
        state = .mainContent(title: "Complete", content: "OrderId: \(approvalResult.data.ecToken)", flowComplete: true)
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
        state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
    }

    func paypalDidCancel(_ payPalClient: PayPalClient) {
        state = .mainContent(title: "Cancelled", content: "User Cancelled", flowComplete: true)
    }

    func paypalDidStart(_ payPalClient: PayPalClient) {
        state = .mainContent(title: "Starting", content: "PayPal is about to start", flowComplete: true)
    }
}
