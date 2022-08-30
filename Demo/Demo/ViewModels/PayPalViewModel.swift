//
//  PayPalViewModel.swift
//  Demo
//
//  Created by Jose Noriega on 30/08/2022.
//

import UIKit
import PayPalNativeCheckout
import PayPalCheckout
import PaymentsCore

class PayPalViewModel: BaseViewModel, PayPalDelegate {

    // MARK: - PayPalDelegate conformance

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
        updateTitle("shipping address changed")
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: Approval) {
        guard let orderId = orderID else {
            updateTitle("native checkout result: \(approvalResult.data.intent.stringValue)")
            return
        }
        updateTitle("order \(orderId): \(approvalResult.data.intent.stringValue)")
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
        updateTitle("an error occurred: \(error.localizedDescription)")
    }

    func paypalDidCancel(_ payPalClient: PayPalClient) {
        updateTitle("order is canceled")
    }

    enum State {
        case initial
        case loading(content: String)
        case payPalReady(title: String, content: String)
        case checkoutWithOrderId(title: String)
        case error(String)
    }

    @Published private(set) var state = State.initial

    private var accessToken = ""

    @Published private(set) var order:Order? = nil

    private var getAccessTokenUseCase = GetAccessToken()

    private let createorderUseCase = CreateOrderUseCase()

    func getAccessToken() {
        Task {
            state = .loading(content: "Getting access token")
            guard let token = await getAccessTokenUseCase.execute() else {
                state = .error("Failed to fetch access token")
                return
            }
            accessToken = token
            state = .payPalReady(title: "Access Token", content: accessToken)
        }
    }

    func createOrder() {
        
    }

    func checkoutWithOrder() {

    }

    func checkoutWithOrderId() {
        state = .checkoutWithOrderId(title: "Check out With OrderID")
    }

    func checkoutWithBillingAgreement() {

    }

    func checkoutWithVault() {
        
    }


    func startNativeCheckoutWithOrderId() {
            guard let orderID = self.orderID else {
                updateTitle("create order first!!")
                return
            }
            Task {
                do {
                    let nativeCheckoutClient = try await getNativeCheckoutClient()
                    nativeCheckoutClient.delegate = self
                    await nativeCheckoutClient.start(orderID: orderID, delegate: self)
                }
                catch {
                    updateTitle(error.localizedDescription)
                }
            }
    }
}
