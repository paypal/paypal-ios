import Foundation

struct PaymentTokenResponse: Decodable {
    
    let id: String
    let customer: Customer
    let paymentSource: PaymentSource
    
   
    enum CodingKeys: String, CodingKey {
        case id
        case customer
        case paymentSource = "payment_source"
    }
}

struct Customer: Decodable {
    
    let id: String
}

struct PaymentSource: Decodable {
    
    let card: BasicCard
}

struct BasicCard: Decodable {
    
    let brand: String?
    let lastDigits: String
    let expiry: String
    
    enum CodingKeys: String, CodingKey {
        case brand
        case lastDigits = "last_digits"
        case expiry
    }
}
