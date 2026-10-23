import Foundation

@_documentation(visibility: private)
public struct GetFundingEligibilityResponse: Decodable {

    let fundingEligibility: FundingEligibilityNode?

    struct FundingEligibilityNode: Decodable {

        let venmo: VenmoFundingEligibility?
    }
}

/// The result of a funding eligibility check for Venmo.
@_documentation(visibility: private)
public struct VenmoFundingEligibility: Decodable {

    /// Whether Venmo is eligible as a funding source.
    public let eligible: Bool

    /// Reasons Venmo may be ineligible, if applicable.
    public let reasons: [String]?
}
