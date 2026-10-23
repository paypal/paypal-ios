import Foundation

struct GetFundingEligibilityVariables: Encodable {

    let clientId: String
    let intent: String
    let currency: String
    let enableFunding: [String]
}
