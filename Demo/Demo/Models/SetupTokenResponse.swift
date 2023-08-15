import Foundation

struct SetUpTokenResponse: Decodable {
    
    let id, status: String
    let customer: Customer?

    struct Customer: Decodable {
        
        let id: String
    }
}
