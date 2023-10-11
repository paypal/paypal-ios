import Foundation
import XCTest
@testable import CardPayments
@testable import CorePayments
@testable import TestShared

class VaultPaymentTokensAPI_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    var sut: VaultPaymentTokensAPI!
    var mockNetworkingClient: MockNetworkingClient!
    let coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    let cardVaultRequest = CardVaultRequest(
        card: Card(
            number: "fake-number",
            expirationMonth: "fake-month",
            expirationYear: "fake-year",
            securityCode: "fake-code",
            cardholderName: "fake-name"
        ),
        setupTokenID: "some-token"
    )
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        
        let mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockNetworkingClient = MockNetworkingClient(http: mockHTTP)
        sut = VaultPaymentTokensAPI(coreConfig: coreConfig, networkingClient: mockNetworkingClient)
    }
    
    // MARK: - updateSetupToken()
    
    func testUpdateSetupToken_constructsGraphQLRequest() async {
        let expectedQueryString = """
            mutation UpdateVaultSetupToken(
                $clientID: String!,
                $vaultSetupToken: String!,
                $paymentSource: PaymentSource
            ) {
                updateVaultSetupToken(
                    clientId: $clientID
                    vaultSetupToken: $vaultSetupToken
                    paymentSource: $paymentSource
                ) {
                    id,
                    status,
                    links {
                        rel,
                        href
                    }
                }
            }
        """
        
        _ = try? await sut.updateSetupToken(cardVaultRequest: cardVaultRequest)
        
        XCTAssertEqual(mockNetworkingClient.capturedGraphQLRequest?.query, expectedQueryString)
        XCTAssertEqual(mockNetworkingClient.capturedGraphQLRequest?.queryNameForURL, "UpdateVaultSetupToken")
        
        let variables = mockNetworkingClient.capturedGraphQLRequest?.variables as! UpdateVaultVariables
        XCTAssertEqual(variables.clientID, "fake-client-id")
        XCTAssertEqual(variables.vaultRequest.setupTokenID, "some-token")
        XCTAssertEqual(variables.vaultRequest.card.number, "fake-number")
        XCTAssertEqual(variables.vaultRequest.card.expiry, "fake-year-fake-month")
        XCTAssertEqual(variables.vaultRequest.card.securityCode, "fake-code")
        XCTAssertEqual(variables.vaultRequest.card.cardholderName, "fake-name")
    }
    
    func testUpdateSetupToken_whenNetworkingClientError_bubblesError() async {
        mockNetworkingClient.stubHTTPError = CoreSDKError(code: 123, domain: "api-client-error", errorDescription: "error-desc")
        
        do {
            _ = try await sut.updateSetupToken(cardVaultRequest: cardVaultRequest)
            XCTFail("Expected error throw.")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.domain, "api-client-error")
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "error-desc")
        }
    }
    
    func testUpdateSetupToken_whenSuccess_returnsParsedUpdateSetupTokenResponse() async throws {
        let successsResponseJSON = """
        {
            "data": {
                "updateVaultSetupToken": {
                    "id": "some-id",
                    "status": "some-status",
                    "links": [
                        {
                            "rel": "some-rel",
                            "href": "some-href"
                        },
                        {
                            "rel": "some-rel-2",
                            "href": "some-href-2"
                        }
                    ]
                }
            }
        }
        """
        
        let data = successsResponseJSON.data(using: .utf8)
        let stubbedHTTPResponse = HTTPResponse(status: 200, body: data)
        mockNetworkingClient.stubHTTPResponse = stubbedHTTPResponse
        
        let response = try await sut.updateSetupToken(cardVaultRequest: cardVaultRequest)
        XCTAssertEqual(response.updateVaultSetupToken.id, "some-id")
        XCTAssertEqual(response.updateVaultSetupToken.status, "some-status")
        XCTAssertEqual(response.updateVaultSetupToken.links.first?.rel, "some-rel")
        XCTAssertEqual(response.updateVaultSetupToken.links.first?.href, "some-href")
        XCTAssertEqual(response.updateVaultSetupToken.links.last?.rel, "some-rel-2")
        XCTAssertEqual(response.updateVaultSetupToken.links.last?.href, "some-href-2")
    }
}
