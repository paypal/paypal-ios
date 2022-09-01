//
//  GetApprovalSessionId.swift
//  Demo
//
//  Created by Jose Noriega on 31/08/2022.
//

import UIKit

final class GetApprovalSessionId {

    func execute(accessToken: String) async throws -> String? {
        let vaultSessionId = try await DemoMerchantAPI.sharedService.createApprovalSessionId(
            accessToken: accessToken,
            approvalSessionRequest: GetApprovalSessionId.approvalSessionIDRequest
        )

        let approvalSessionIdLink = vaultSessionId.links.first { $0.rel == "approve" }
        if let hrefLink = approvalSessionIdLink?.href {
            return URLComponents(string: hrefLink)?.queryItems?.first { $0.name == "approval_session_id" }?.value
        }
        return nil
    }

    private static let approvalSessionIDRequest = """
        {
            "customer_id": "abcd1234",
            "source": {
                "paypal": {
                "usage_type": "MERCHANT",
                    "customer_type": "CONSUMER"
                }
            },
            "application_context": {
                "locale": "en-US",
                "return_url": "https://example.com",
                "cancel_url": "https://example.com",
                "payment_method_preference": {
                    "payee_preferred": "IMMEDIATE_PAYMENT_REQUIRED",
                    "payer_selected": "PAYPAL"
                }
            }
        }
        """
}
