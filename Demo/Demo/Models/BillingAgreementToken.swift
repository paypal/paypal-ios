import UIKit

struct BillingAgreementToken: Codable {

    enum CodingKeys: String, CodingKey {
        case tokenID = "token_id"
    }
    let tokenID: String
}
