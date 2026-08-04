import CorePayments

struct ShopperSessionContext {
    
    let sessionType: PayPalSessionType
    let userIdentity: PayPalUserIdentity?
    let urlConfig: PayPalURLConfig
    let userAction: PayPalUserAction
}
