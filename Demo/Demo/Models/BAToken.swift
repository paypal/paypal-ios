import UIKit

struct BAToken: Codable {

    enum CodingKeys: String, CodingKey {
        case tokenID = "token_id"
    }
    let tokenID: String
}
