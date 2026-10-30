import Foundation

struct PaymentTokenResponse: Decodable, Equatable, Hashable {
    
    let id: String
    let customer: Customer
    let paymentSource: PaymentSource
}

struct Customer: Codable, Equatable, Hashable {

    let id: String
}

struct PaymentSource: Decodable, Equatable, Hashable {
    
    var card: CardPaymentSource?
    var paypal: PayPalPaymentSource?
}

struct CardPaymentSource: Decodable, Equatable, Hashable {

    let brand: String?
    let lastDigits: String
    let expiry: String
}

struct PayPalPaymentSource: Decodable, Equatable, Hashable {

    let emailAddress: String
}
