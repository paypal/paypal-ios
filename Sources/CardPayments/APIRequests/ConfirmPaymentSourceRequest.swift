import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Describes request to confirm a payment source (approve an order)
struct ConfirmPaymentSourceRequest: Encodable {
    
    // MARK: - Coding Keys
    
    private enum TopLevelKeys: String, CodingKey {
        case paymentSource = "payment_source"
        case applicationContext = "application_context"
    }
    
    private  enum ApplicationContextKeys: String, CodingKey {
        case returnURL = "return_url"
        case cancelURL = "cancel_url"
    }
    
    private enum PaymentSourceKeys: String, CodingKey {
        case card
    }
    
    private enum CardKeys: String, CodingKey {
        case number
        case expiry
        case billingAddress
        case name
        case attributes
    }
    
    private enum BillingAddressKeys: String, CodingKey {
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case adminArea1 = "admin_area_1"
        case adminArea2 = "admin_area_2"
        case postalCode
        case countryCode
    }
    
    private enum AttributesKeys: String, CodingKey {
        case vault
        case verification
    }
    
    private enum VerificationKeys: String, CodingKey {
        case method
    }
    
    // MARK: - Internal Properties
    // Exposed for testing
    
    let returnURL = PayPalCoreConstants.callbackURLScheme + "://card/success"
    let cancelURL = PayPalCoreConstants.callbackURLScheme + "://card/cancel"
    let cardRequest: CardRequest
    
    // MARK: - Initializer
    
    init(cardRequest: CardRequest) {
        self.cardRequest = cardRequest
    }
    
    // MARK: - Custom Encoder
    
    func encode(to encoder: Encoder) throws {
        var topLevel = encoder.container(keyedBy: TopLevelKeys.self)
        
        var applicationContext = topLevel.nestedContainer(keyedBy: ApplicationContextKeys.self, forKey: .applicationContext)
        try applicationContext.encode(returnURL, forKey: .returnURL)
        try applicationContext.encode(cancelURL, forKey: .cancelURL)
        
        var paymentSource = topLevel.nestedContainer(keyedBy: PaymentSourceKeys.self, forKey: .paymentSource)
        var card = paymentSource.nestedContainer(keyedBy: CardKeys.self, forKey: .card)
        try card.encode(cardRequest.card.number, forKey: .number)
        try card.encode("\(cardRequest.card.expirationYear)-\(cardRequest.card.expirationMonth)", forKey: .expiry)
        try card.encodeIfPresent(cardRequest.card.cardholderName, forKey: .name)

        if let cardBillingInfo = cardRequest.card.billingAddress {
            var billingAddress = card.nestedContainer(keyedBy: BillingAddressKeys.self, forKey: .billingAddress)
            try billingAddress.encodeIfPresent(cardBillingInfo.addressLine1, forKey: .addressLine1)
            try billingAddress.encodeIfPresent(cardBillingInfo.addressLine2, forKey: .addressLine2)
            try billingAddress.encodeIfPresent(cardBillingInfo.postalCode, forKey: .postalCode)
            try billingAddress.encodeIfPresent(cardBillingInfo.region, forKey: .adminArea1)
            try billingAddress.encodeIfPresent(cardBillingInfo.locality, forKey: .adminArea2)
            try billingAddress.encodeIfPresent(cardBillingInfo.countryCode, forKey: .countryCode)
        }
        
        var attributes = card.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        var verification = attributes.nestedContainer(keyedBy: VerificationKeys.self, forKey: .verification)
        try verification.encode(cardRequest.sca.rawValue, forKey: .method)
    }
}
