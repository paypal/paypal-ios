import Foundation

struct SetUpTokenResponse: Decodable, Equatable {

    static func == (lhs: SetUpTokenResponse, rhs: SetUpTokenResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    let id, status: String
    let customer: Customer?
    let links: [Link]
    var paypalURL: String? {
        if let link = links.first(where: { $0.rel == "approve" }) {
            let url = link.href
            return url
        }
        return nil
    }

    struct Customer: Decodable {
        
        let id: String
    }

    struct Link: Decodable {

        let href, rel, method: String
    }
}
