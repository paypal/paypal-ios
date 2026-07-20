import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// Coordinates the GraphQL call that pre-warms a Shopper Session with app-switch eligibility.
@_documentation(visibility: private)
public class CreateShopperSessionAPI {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient
    private let authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI

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
        self.authenticationSecureTokenServiceAPI = AuthenticationSecureTokenServiceAPI(coreConfig: coreConfig)
    }

    /// Exposed for injecting `MockNetworkingClient` / `MockAuthenticationSecureTokenServiceAPI` in tests.
    init(
        coreConfig: CoreConfig,
        networkingClient: NetworkingClient,
        authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI
    ) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
        self.authenticationSecureTokenServiceAPI = authenticationSecureTokenServiceAPI
    }

    // MARK: - Internal Methods

    /// Creates a Shopper Session with app-switch eligibility and returns the full result.
    /// - Parameters:
    ///   - urlConfig: Return, cancel, and fallback deep-link URLs registered with PayPal.
    ///   - userIdentity: Optional buyer identity. The email address (`buyerEmailAddressMerchantPassed`),
    ///     existing PayPal session id (`shoppersSessionId`), and phone (split into
    ///     `countryCode` / `nationalNumber`) are forwarded to the GQL mutation.
    /// - Returns: A `ShopperSessionResult` containing eligibility, redirect URL, and session config.
    /// - Throws: A `CoreSDKError` if the network call or response parsing fails.
    func createShopperSessionWithAppSwitchEligibility(
        urlOpener: URLOpener,
        urlConfig: PayPalURLConfig,
        userIdentity: PayPalUserIdentity?
    ) async throws -> ShopperSessionResult {

        let contextId = UUID().uuidString
        let tokenType = TokenType.orderID

        let experimentationContext = ShopperSessionExperimentationContext(merchantAccountId: coreConfig.merchantID)
        
        let isOsloAppInstalled = urlOpener.isOsloAppInstalled()
        
        let appSwitchEligibilityInput = AppSwitchEligibilityInput(
            contextId: contextId,
            tokenType: tokenType,
            osType: PayPalCoreConstants.osType,
            merchantOptInForAppSwitch: true,
            paypalNativeAppInstalled: isOsloAppInstalled,
            experimentationContext: experimentationContext,
            buyerEmailAddressMerchantPassed: userIdentity?.email,
            shoppersSessionId: userIdentity?.existingPayPalSessionID
        )

        let phoneInput = userIdentity?.phone.map {
            PhoneInput(countryCode: $0.countryCode, nationalNumber: $0.nationalNumber)
        }

        let shopperSessionInput = ShopperSessionInput(
            returnAppUrl: urlConfig.returnAppURL.absoluteString,
            cancelAppUrl: urlConfig.cancelAppURL.absoluteString,
            sdkVersion: PayPalCoreConstants.payPalSDKVersion,
            fallbackUrlScheme: urlConfig.fallbackSchemeURL?.absoluteString,
            phone: phoneInput
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

        let lsat = try await authenticationSecureTokenServiceAPI.createLowScopedAccessToken().accessToken

        let httpResponse = try await networkingClient.fetch(
            request: graphQLRequest,
            additionalHeaders: [.authorization: "Bearer \(lsat)"]
        )

        let parsed: CreateShopperSessionResponse = try HTTPResponseParser()
            .parseGraphQL(httpResponse, as: CreateShopperSessionResponse.self)

        guard let result = parsed.shopperSession else {
            throw NetworkingError.noGraphQLDataKey
        }

        return result
    }
}
