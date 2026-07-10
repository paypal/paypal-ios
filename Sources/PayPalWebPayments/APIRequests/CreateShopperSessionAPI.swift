import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(CorePayments)
import CorePayments
#endif

/// Coordinates the GraphQL call that pre-warms a Shopper Session with app-switch eligibility.
@_documentation(visibility: private)
public class CreateShopperSessionAPI {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient

    private let createShopperSessionQuery = """
        mutation CreateShopperSessionWithAppSwitchEligibility(
            $appSwitchEligibilityInput: externalAppSwitchEligibilityInput
            $shopperSessionInput: externalShopperSessionInput
        ) {
            external {
                createShopperSessionWithAppSwitchEligibility(
                    appSwitchEligibilityInput: $appSwitchEligibilityInput
                    shopperSessionInput: $shopperSessionInput
                ) {
                    appSwitchEligibilityResponse {
                        appSwitchEligible
                        ineligibleReason
                        checkoutUrls {
                            redirectURL
                            checkoutFallbackUrl
                        }
                    }
                    shopperSessionResponse {
                        sessionId
                        expiresAt
                    }
                }
            }
        }
        """

    // MARK: - Initializer

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }

    /// Exposed for injecting `MockNetworkingClient` in tests.
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }

    // MARK: - Internal Methods

    /// Creates a Shopper Session with app-switch eligibility and returns the full result.
    /// - Parameters:
    ///   - contextId: A merchant-provided context identifier for the session (e.g. order ID or correlation ID).
    ///   - token: The merchant token value (order ID or client token).
    ///   - tokenType: The type of token — use `ExternalTokenKind.orderId` or `ExternalTokenKind.clientToken`.
    ///   - urlConfig: Return, cancel, and fallback deep-link URLs registered with PayPal.
    ///   - userIdentity: Optional buyer identity. The email address is forwarded to the GQL mutation.
    /// - Returns: A `ShopperSessionResult` containing eligibility, redirect URL, and session config.
    /// - Throws: A `CoreSDKError` if the network call or response parsing fails.
    func createShopperSessionWithAppSwitchEligibility(
        contextId: String,
        token: String,
        tokenType: String,
        urlConfig: PayPalURLConfig,
        userIdentity: PayPalUserIdentity?
    ) async throws -> ShopperSessionResult {

        let experimentationContext = ExperimentationContext(
            appSwitchSupported: true,
            merchantCountry: "US",
            integrationChannel: PayPalCoreConstants.integrationChannel,
            isWebLLSEligible: false,
            isWebView: false,
            paymentType: "PAY",
            buyerGUID: nil,
            merchantAccountId: coreConfig.merchantID.isEmpty ? nil : coreConfig.merchantID
        )

        let appSwitchEligibilityInput = AppSwitchEligibilityInput(
            contextId: contextId,
            tokenType: tokenType,
            osType: PayPalCoreConstants.osType,
            merchantOptInForAppSwitch: true,
            paypalNativeAppInstalled: true,
            experimentationContext: experimentationContext,
            buyerEmailAddressMerchantPassed: userIdentity?.email
        )

        let shopperSessionInput = ShopperSessionInput(
            returnAppUrl: urlConfig.returnAppURL.absoluteString,
            cancelAppUrl: urlConfig.cancelAppURL.absoluteString,
            sdkVersion: PayPalCoreConstants.payPalSDKVersion,
            fallbackUrlScheme: urlConfig.fallbackSchemeURL?.absoluteString
        )

        let variables = CreateShopperSessionVariables(
            appSwitchEligibilityInput: appSwitchEligibilityInput,
            shopperSessionInput: shopperSessionInput
        )

        let graphQLRequest = GraphQLRequest(
            query: createShopperSessionQuery,
            variables: variables,
            queryNameForURL: nil
        )

        let httpResponse = try await networkingClient.fetch(request: graphQLRequest)

        let parsed: CreateShopperSessionResponse = try HTTPResponseParser()
            .parseGraphQL(httpResponse, as: CreateShopperSessionResponse.self)

        guard let result = parsed.shopperSession else {
            throw NetworkingError.noGraphQLDataKey
        }

        return result
    }
}
