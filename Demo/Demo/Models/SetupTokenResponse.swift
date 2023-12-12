import Foundation

struct SetUpTokenResponse: Decodable, Equatable {

    static func == (lhs: SetUpTokenResponse, rhs: SetUpTokenResponse) -> Bool {
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
