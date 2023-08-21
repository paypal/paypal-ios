import Foundation

struct SetUpTokenResponse: Decodable, Equatable {

    static func == (lhs: SetUpTokenResponse, rhs: SetUpTokenResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    let id, status: String
    let customer: Customer?

    struct Customer: Decodable {
        
        let id: String
    }
}
