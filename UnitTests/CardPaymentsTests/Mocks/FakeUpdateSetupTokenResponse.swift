@testable import CardPayments

enum FakeUpdateSetupTokenResponse {

    static let withValid3DSURL = UpdateSetupTokenResponse(
        updateVaultSetupToken: TokenDetails(
        id: "testSetupTokenId",
        status: "PAYER_ACTION_REQUIRED",
        links: [
            TokenDetails.Link(
                rel: "approve",
                href: "https://www.sandbox.paypal.com/webapps/helios?action=authenticate&token=testSetupTokenId"
            )
        ]
        )
    )

    static let withInvalid3DSURL = UpdateSetupTokenResponse(
        updateVaultSetupToken: TokenDetails(
        id: "testSetupTokenId",
        status: "PAYER_ACTION_REQUIRED",
        links: [
            TokenDetails.Link(
                rel: "approve",
                href: "https://www.sandbox.paypal.com/"
            )
        ]
        )
    )

    static let without3DS = UpdateSetupTokenResponse(
        updateVaultSetupToken: TokenDetails(
        id: "testSetupTokenId",
        status: "APPROVED",
        links: [
            TokenDetails.Link(
                rel: "approve",
                href: "https://www.sandbox.paypal.com/"
            )
        ]
        )
    )
}
