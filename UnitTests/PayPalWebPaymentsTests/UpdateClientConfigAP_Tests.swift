import Foundation
import XCTest
@testable import PayPalWebPayments
@testable import CorePayments
@testable import TestShared

class UpdateClientConfigAPI_Tests: XCTestCase {

    // MARK: - Helper Properties

    var sut: UpdateClientConfigAPI!
    var mockNetworkingClient: MockNetworkingClient!
    let coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    let request = PayPalWebCheckoutRequest(
        orderID: "testID",
        fundingSource: .card
    )

    // MARK: - Test Lifecycle

    override func setUp() {
        super.setUp()

        let mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockNetworkingClient = MockNetworkingClient(http: mockHTTP)
        sut = UpdateClientConfigAPI(coreConfig: coreConfig, networkingClient: mockNetworkingClient)
    }

    // MARK: - updateSetupToken()

    func testUpdateClientConfig_constructsGraphQLRequest() async {
        let expectedQueryString = """
            mutation UpdateClientConfig(
                $orderID: String!,
                $fundingSource: ButtonFundingSourceType!,
                $integrationArtifact: IntegrationArtifactType!,
                $userExperienceFlow: UserExperienceFlowType!,
                $productFlow: ProductFlowType!,
                $productChannel: ProductChannel!
            ) {
                updateClientConfig(
                    token: $orderID
                    fundingSource: $fundingSource
                    integrationArtifact: $integrationArtifact,
                    userExperienceFlow: $userExperienceFlow,
                    productFlow: $productFlow,
                    channel: $productChannel
                )
            }
        """

        _ = try? await sut.updateClientConfig(request: request)
        XCTAssertEqual(mockNetworkingClient.capturedGraphQLRequest?.query, expectedQueryString)
        XCTAssertEqual(mockNetworkingClient.capturedGraphQLRequest?.queryNameForURL, "UpdateClientConfig")

        let variables = mockNetworkingClient.capturedGraphQLRequest?.variables as! UpdateClientConfigVariables
        XCTAssertEqual(variables.orderID, "testID")
        XCTAssertEqual(variables.integrationArtifact, "MOBILE_SDK")
        XCTAssertEqual(variables.userExperienceFlow, "INCONTEXT")
        XCTAssertEqual(variables.productFlow, "HERMES")
        XCTAssertEqual(variables.channel, "MOBILE_APP")
    }

    func testUpdateClientConfig_whenNetworkingClientError_bubblesError() async {
        mockNetworkingClient.stubHTTPError = CoreSDKError(code: 123, domain: "api-client-error", errorDescription: "error-desc")

        do {
            _ = try await sut.updateClientConfig(request: request)
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
            "updateClientConfig": "some value"
            }
        }
        """

        let data = successsResponseJSON.data(using: .utf8)
        let stubbedHTTPResponse = HTTPResponse(status: 200, body: data)
        mockNetworkingClient.stubHTTPResponse = stubbedHTTPResponse

        let response = try await sut.updateClientConfig(request: request)
        XCTAssertNotNil(response.updateClientConfig)
    }
}
