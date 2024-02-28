import Foundation

struct CreateSetupTokenResponse: Decodable, Equatable {

    static func == (lhs: CreateSetupTokenResponse, rhs: CreateSetupTokenResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    let id, status: String
    let customer: Customer?
    let links: [Link]
    var paypalURL: String? {
        links.first { $0.rel == "approve" }?.href
    }

    struct Customer: Decodable {
        
        let id: String
    }

    struct Link: Decodable {

        let href, rel, method: String
    }
}
