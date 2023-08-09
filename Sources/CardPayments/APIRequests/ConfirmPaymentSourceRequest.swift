import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Describes request to confirm a payment source (approve an order)
struct ConfirmPaymentSourceRequest: Encodable {
    
    // MARK: - Coding Keys
    
    enum TopLevelKeys: String, CodingKey {
        case paymentSource = "payment_source"
        case applicationContext = "application_context"
    }
    
    enum ApplicationContextKeys: String, CodingKey {
        case returnURL = "return_url"
        case cancelURL = "cancel_url"
    }
    
    enum PaymentSourceKeys: String, CodingKey {
        case card
    }
    
    enum CardKeys: String, CodingKey {
        case number
        case expiry
        case billingAddress
        case name
        case attributes
    }
    
    enum BillingAddressKeys: String, CodingKey {
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case adminArea1 = "admin_area_1"
        case adminArea2 = "admin_area_2"
        case postalCode
        case countryCode
    }
    
    enum AttributesKeys: String, CodingKey {
        case customer
        case vault
        case verification
    }
    
    enum CustomerKeys: String, CodingKey {
        case id
    }
    
    enum VaultKeys: String, CodingKey {
        case storeInVault
    }
    
    enum VerificationKeys: String, CodingKey {
        case method
    }
    
    // MARK: - Properties
    
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
        try card.encode(cardRequest.card.cardholderName, forKey: .name)

        if let cardBillingInfo = cardRequest.card.billingAddress {
            var billingAddress = card.nestedContainer(keyedBy: BillingAddressKeys.self, forKey: .billingAddress)
            try billingAddress.encode(cardBillingInfo.addressLine1, forKey: .addressLine1)
            try billingAddress.encode(cardBillingInfo.addressLine2, forKey: .addressLine2)
            try billingAddress.encode(cardBillingInfo.postalCode, forKey: .postalCode)
            try billingAddress.encode(cardBillingInfo.region, forKey: .adminArea1)
            try billingAddress.encode(cardBillingInfo.locality, forKey: .adminArea2)
            try billingAddress.encode(cardBillingInfo.countryCode, forKey: .countryCode)
        }
        var attributes = card.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        var customer = attributes.nestedContainer(keyedBy: CustomerKeys.self, forKey: .customer)
        try customer.encode("fake-customer-id", forKey: .id) // TODO
        
        var vault = attributes.nestedContainer(keyedBy: VaultKeys.self, forKey: .vault)
        try vault.encode("ON_SUCCESS", forKey: .storeInVault) // TODO
        
        var verification = attributes.nestedContainer(keyedBy: VerificationKeys.self, forKey: .verification)
        try verification.encode(cardRequest.sca.rawValue, forKey: .method) //TODO
    }
}

//{
//    "payment_source": {
//        "card": {
//            "number": "4111111111111111",
//            "expiry": "2020-02",
//            "name": "John Doe",
//            "billing_address": {
//                "address_line_1": "2211 N First Street",
//                "address_line_2": "Building 17",
//                "admin_area_2": "San Jose",
//                "admin_area_1": "CA",
//                "postal_code": "95131",
//                "country_code": "US"
//            },
//            "attributes": {
//                "customer": {
//                    "id": "wxj1234"
//                },
//                "vault": {
//                    "store_in_vault": "ON_SUCCESS"
//                },
//                "verification": {
//                    "method": "SCA_WHEN_REQUIRED"
//                }
//            }
//        }
//    },
//    "application_context": {
//        "return_url": "return_url",
//        "cancel_url": "return_url"
//    }
//}
