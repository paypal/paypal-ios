//
//  PayPalViewModel.swift
//  Demo
//
//  Created by Jose Noriega on 30/08/2022.
//

import UIKit

class PayPalViewModel: ObservableObject {

    enum State {
        case initial
        case loading(content: String)
        case payPalReady(title: String, content: String)
        case error(String)
    }

    @Published private(set) var state = State.initial

    private var accessToken = ""

    private var getAccessTokenUseCase = GetAccessToken()

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

    func checkoutWithOrder() {

    }

    func checkoutWithOrderId() {

    }

    func checkoutWithBillingAgreement() {

    }

    func checkoutWithVault() {
        
    }
}
