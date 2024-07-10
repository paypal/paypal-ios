import Foundation

struct CreateSetupTokenResponse: Decodable, Equatable {

    static func == (lhs: CreateSetupTokenResponse, rhs: CreateSetupTokenResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    let id, status: String
    let customer: Customer?

    struct Customer: Decodable {
        
        let id: String
    }
}
