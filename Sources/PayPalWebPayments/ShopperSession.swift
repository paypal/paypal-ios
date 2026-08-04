import Foundation

protocol ShopperSession {
    
    var sessionDetails: ShopperSessionResult { get async throws }
    
    var shopperSessionID: String? { get }
    var tokenType: TokenType? { get }
    var state: ShopperSessionState { get }
    
    var orderID: String? { get set }
    var setupTokenID: String? { get set }
    var appSwitchURL: URL? { get set }

    func bind(to context: ShopperSessionContext)
    
    func reset()
    func trackEvent(_ event: PayPalAnalyticsEvent)
    func trackEvent(_ event: PayPalAnalyticsEvent, withBackgroundProtection backgroundProtection: Bool)
}
