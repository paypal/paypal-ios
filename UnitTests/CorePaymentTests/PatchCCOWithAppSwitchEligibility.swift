// swiftlint:disable indentation_width

import Foundation
import XCTest
@testable import CorePayments
@testable import TestShared

final class PatchCCOWithAppSwitchEligibility_Tests: XCTestCase {

    private var sut: PatchCCOWithAppSwitchEligibility!
    private var mockNetworkingClient: MockNetworkingClient!
    private let coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    private let expectedQueryString = """
        mutation PatchCcoWithAppSwitchEligibility(
            $contextId: String!,
            $experimentationContext: externalExperimentationContextInput,
            $osType: externalOSType!,
            $merchantOptInForAppSwitch: Boolean!,
            $token: externalToken!,
            $tokenType: externalTokenType!,
            $integrationArtifact: externalIntegrationArtifactType!
        ) {
            external {
                patchCcoWithAppSwitchEligibility(
                    appSwitchEligibilityInput: {
                        contextId: $contextId,
                        experimentationContext: $experimentationContext,
                        merchantOptInForAppSwitch: $merchantOptInForAppSwitch,
                        osType: $osType,
                        token: $token,
                        tokenType: $tokenType
                    },
                    patchCcoInput: {
                        token: $token,
                        clientConfig: {
                            integrationArtifact: $integrationArtifact
                        }
                    }
                ) {
                    appSwitchEligibility {
                        appSwitchEligible
                        redirectURL
                        ineligibleReason
                    }
                }
            }
        }
        """

    override func setUp() {
        super.setUp()
        let mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockNetworkingClient = MockNetworkingClient(http: mockHTTP)
        sut = PatchCCOWithAppSwitchEligibility(
            coreConfig: coreConfig,
            networkingClient: mockNetworkingClient,
        )
    }

    override func tearDown() {
        sut = nil
        mockNetworkingClient = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_patchCCO_constructsGraphQLRequest_variables_headers_and_clientContext() async throws {

        let token = "ctx_abc123"
        let tokenType = "CLIENT_TOKEN"

        let successJSON = """
        {
        "data": {
            "external": {
              "patchCcoWithAppSwitchEligibility": {
                "appSwitchEligibility": {
                  "appSwitchEligible": true,
                  "redirectURL": "paypal://app-switch",
                  "ineligibleReason": null
                }
              }
            }
          }
        }
        """

        mockNetworkingClient.stubHTTPResponse = HTTPResponse(status: 200, body: successJSON.data(using: .utf8))
        let result = try await sut.patchCCOWithAppSwitchEligibility(token: token, tokenType: tokenType)
        XCTAssertEqual(result.appSwitchEligible, true)
        XCTAssertEqual(result.redirectURL, "paypal://app-switch")
        XCTAssertNil(result.ineligibleReason)

        XCTAssertNotNil(mockNetworkingClient.capturedGraphQLRequest?.query)
        if let query = mockNetworkingClient.capturedGraphQLRequest?.query {
            let normalizedQuery = normalizeGraphQLString(query)
            let normalizedExpected = normalizeGraphQLString(expectedQueryString)
            XCTAssertEqual(normalizedQuery, normalizedExpected)
        }

        XCTAssertNil(mockNetworkingClient.capturedGraphQLRequest?.queryNameForURL)

        let vars = try XCTUnwrap(
            mockNetworkingClient.capturedGraphQLRequest?.variables as? PatchCcoWithAppSwitchEligibilityVariables
        )
        XCTAssertEqual(vars.contextId, token)
        XCTAssertEqual(vars.experimentationContext?.integrationChannel, "PPCP_NATIVE_SDK")
        XCTAssertEqual(vars.osType, "IOS")
        XCTAssertTrue(vars.merchantOptInForAppSwitch)
        XCTAssertEqual(vars.token, token)
        XCTAssertEqual(vars.tokenType, tokenType)
        XCTAssertEqual(vars.integrationArtifact, "MOBILE_SDK")
        XCTAssertEqual(vars.paypalNativeAppInstalled, true)

        XCTAssertEqual(mockNetworkingClient.capturedClientContext, token)
    }

    func test_patchCCO_bubblesNetworkingError() async {
        mockNetworkingClient.stubHTTPError = CoreSDKError(code: 999, domain: "networking", errorDescription: "boom")

        do {
            _ = try await sut.patchCCOWithAppSwitchEligibility(token: "t", tokenType: "CLIENT_TOKEN")
            XCTFail("Expected error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, "networking")
            XCTAssertEqual(error.code, 999)
            XCTAssertEqual(error.localizedDescription, "boom")
        } catch {
            XCTAssert(false, "Expected CoreSDKError: \(error)")
        }
    }

    func test_patchCCO_whenMissingEligibility_throwsNoGraphQLDataKey() async {
        let missingEligibilityJSON = """
        {
          "data": {
            "external": {
              "patchCcoWithAppSwitchEligibility": {
              }
            }
          }
        }
        """
        mockNetworkingClient.stubHTTPResponse = HTTPResponse(status: 200, body: missingEligibilityJSON.data(using: .utf8))

        do {
            _ = try await sut.patchCCOWithAppSwitchEligibility(token: "t", tokenType: "CLIENT_TOKEN")
            XCTFail("Expected NetworkingError.noGraphQLDataKey")
        } catch let error as CoreSDKError {
            guard NetworkingError.noGraphQLDataKey == error else {
                return XCTFail("Expected NetworkingError.noGraphQLDataKey, got \(error)")
            }
        } catch {
            return XCTFail("Expected NetworkingError.noGraphQLDataKey, got \(error)")
        }
    }

    func test_patchCCO_success_returnsParsedEligibility_falseReasoned() async throws {
        let body = """
        {
          "data": {
            "external": {
              "patchCcoWithAppSwitchEligibility": {
                "appSwitchEligibility": {
                  "appSwitchEligible": false,
                  "redirectURL": null,
                  "ineligibleReason": "NO_INSTALLED_APP"
                }
              }
            }
          }
        }
        """
        mockNetworkingClient.stubHTTPResponse = HTTPResponse(status: 200, body: body.data(using: .utf8))

        let response = try await sut.patchCCOWithAppSwitchEligibility(token: "tok", tokenType: "CLIENT_TOKEN")

        XCTAssertEqual(response.appSwitchEligible, false)
        XCTAssertNil(response.redirectURL)
        XCTAssertEqual(response.ineligibleReason, "NO_INSTALLED_APP")
    }

    // MARK: - Helper Methods

    private func normalizeGraphQLString(_ string: String) -> String {
        return string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s*\\{\\s*", with: "{", options: .regularExpression)
            .replacingOccurrences(of: "\\s*\\}\\s*", with: "}", options: .regularExpression)
            .replacingOccurrences(of: "\\s*\\(\\s*", with: "(", options: .regularExpression)
            .replacingOccurrences(of: "\\s*\\)\\s*", with: ")", options: .regularExpression)
    }
}
