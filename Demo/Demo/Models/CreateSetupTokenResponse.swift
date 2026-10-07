import Foundation

// TODO: rename to SetupToken (or DemoSetupToken)
struct CreateSetupTokenResponse: Decodable, Equatable, Hashable {

    static func == (lhs: CreateSetupTokenResponse, rhs: CreateSetupTokenResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    let id, status: String
    let customer: Customer?

    struct Customer: Decodable, Hashable {
        
        let id: String
    }

    enum CodingKeys: String, CodingKey {
        case id, status, customer
    }

    /// The Live merchant returns `id` and a redirect URL but no `status`.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        customer = try container.decodeIfPresent(Customer.self, forKey: .customer)
    }
}
