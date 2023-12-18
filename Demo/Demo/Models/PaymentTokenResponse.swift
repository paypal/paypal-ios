import Foundation

struct PaymentTokenResponse: Decodable, Equatable {
    
    let id: String
    let customer: Customer
    let paymentSource: PaymentSource
}

struct Customer: Codable, Equatable {

    let id: String
}

struct PaymentSource: Decodable, Equatable {
    
    var card: CardPaymentSource?
    var paypal: PayPalPaymentSource?
}

struct CardPaymentSource: Decodable, Equatable {

    let brand: String?
    let lastDigits: String
    let expiry: String
}

struct PayPalPaymentSource: Decodable, Equatable {

    let emailAddress: String
}
