import Foundation

struct PaymentTokenResponse: Decodable, Equatable {
    
    let id: String
    let customer: Customer
    let paymentSource: PaymentSource
    
   
    enum CodingKeys: String, CodingKey {
        case id
        case customer
        case paymentSource = "payment_source"
    }
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
    
    enum CodingKeys: String, CodingKey {
        case brand
        case lastDigits = "last_digits"
        case expiry
    }
}
