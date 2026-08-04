import Foundation
import CorePayments
import UIKit

class PayPalShopperSession: ShopperSession {
    var shopperSessionID: String? {
        analyticsData?.shopperSessionID
    }
    
    var tokenType: TokenType? {
        context?.sessionType.tokenType
    }
    
    var appSwitchURL: URL?
    
    
    /// Holds the in-flight or completed Shopper Session fetch.
    /// Set by `createPayPalSession()`. Cleared automatically on checkout success, cancellation, or error.
    private var sessionTask: Task<ShopperSessionResult, Error>?

    // MARK: - Analytics State
    private var context: ShopperSessionContext?
    
    private var analyticsData: PayPalCheckoutAnalyticsData?
    private var analyticsService: AnalyticsService?
    
    private let config: CoreConfig
    private let urlOpener: URLOpener
    private let createShopperSessionAPI: CreateShopperSessionAPI
    
    private(set) var state: ShopperSessionState = .idle
    
    var orderID: String? {
        didSet {
            if let orderID {
                analyticsService = AnalyticsService(coreConfig: config, orderID: orderID)
            }
        }
    }
    
    var setupTokenID: String? {
        didSet {
            if let setupTokenID {
                analyticsService = AnalyticsService(coreConfig: config, setupToken: setupTokenID)
            }
        }
    }

    var sessionDetails: ShopperSessionResult {
        get async throws {
            // TODO: throw session not created error here when session task is nil
            return try await sessionTask!.value
        }
    }


    convenience init(config: CoreConfig) {
        self.init(
            config: config,
            urlOpener: UIApplication.shared,
            analyticsService: AnalyticsService(coreConfig: config),
            createShopperSessionAPI: CreateShopperSessionAPI(coreConfig: config)
        )
    }
    
    // for testing only
    init(
        config: CoreConfig,
        urlOpener: URLOpener,
        analyticsService: AnalyticsService,
        createShopperSessionAPI: CreateShopperSessionAPI
    ) {
        self.config = config
        self.urlOpener = urlOpener
        self.analyticsService = analyticsService
        self.createShopperSessionAPI = createShopperSessionAPI
    }
    
    func bind(to context: ShopperSessionContext) {
        self.context = context
        
        let tokenType = context.sessionType.tokenType
        sessionTask = Task {
            let result = try await createShopperSessionAPI.createShopperSessionWithAppSwitchEligibility(
                tokenType: tokenType,
                urlOpener: urlOpener,
                urlConfig: context.urlConfig,
                userIdentity: context.userIdentity,
                analyticsData: analyticsData
            )
            state = .initialized
            return result
        }
        analyticsData = PayPalCheckoutAnalyticsData(
            tokenType: tokenType,
            userIdentity: context.userIdentity,
            urlConfig: context.urlConfig,
            userAction: context.userAction
        )
        analyticsService?.sendEvent("paypal-web-payments:checkout:ssid-session:started")
    }
    
    func reset() {
        sessionTask?.cancel()
        // clear existing session context
        context = nil
        state = .idle
    }
    
    func trackEvent(_ event: PayPalAnalyticsEvent) {
        analyticsService?.sendEvent(
            event.canonicalName,
            errorDescription: event.errorDescription,
            checkoutAnalyticsData: analyticsData
        )
    }
    
    func trackEvent(_ event: PayPalAnalyticsEvent, withBackgroundProtection backgroundProtection: Bool) {
        analyticsService?.sendEvent(
            event.canonicalName,
            errorDescription: event.errorDescription,
            checkoutAnalyticsData: analyticsData,
            withBackgroundProtection: backgroundProtection
        )

    }
}
