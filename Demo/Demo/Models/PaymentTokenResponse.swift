import Foundation

struct PaymentTokenResponse: Decodable, Equatable {
    
    let id: String
    let customer: Customer
    let paymentSource: PaymentSource
}

struct Customer: Decodable, Equatable {
    
    let id: String
}

struct PaymentSource: Decodable, Equatable {
    
    let card: BasicCard
}

struct BasicCard: Decodable, Equatable {
    
    let brand: String?
    let lastDigits: String
    let expiry: String
}
