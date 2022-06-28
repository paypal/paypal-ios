import XCTest
@testable import PaymentsCore
@testable import Card

class EligibilityParsing_Tests: XCTestCase {

    func testFundingEligibility_matchesResponse() throws {
        let jsonData = validFundingEligibilityResponse.data(using: .utf8)!
        let fundingEligibilityObject = try! JSONDecoder().decode(FundingEligibilityResponse.self, from: jsonData)

        XCTAssertTrue(fundingEligibilityObject.fundingEligibility.venmo.eligible == true)
        XCTAssertTrue(fundingEligibilityObject.fundingEligibility.card.eligible == false)
    }

    let validFundingEligibilityResponse = """
        {
            "fundingEligibility": {
                "venmo": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible",
                        "VENMO OPT-IN WITH ENABLE_FUNDING"
                    ]
                },
                "card": {
                    "eligible": false
                },
                "paypal": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible"
                    ]
                },
                "paylater": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible",
                        "CRC OFFERS SERV CALLED: Trmt_xo_xobuyernodeserv_call_crcoffersserv",
                        "CRC OFFERS SERV ELIGIBLE"
                    ]
                },
                "credit": {
                    "eligible": false,
                    "reasons": [
                        "INELIGIBLE DUE TO PAYLATER ELIGIBLE"
                    ]
                }
            }
        }
        """
}
