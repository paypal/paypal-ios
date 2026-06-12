import Foundation
import UIKit

#if canImport(CorePayments)
import CorePayments
#endif

protocol CreateShopperSessionAPIProtocol {
    func createShopperSessionForCheckout(
        request: PayPalWebCheckoutRequest,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool
    ) async throws -> ShopperSessionWithAppSwitchEligibility

    func createShopperSessionForVault(
        request: PayPalVaultRequest,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool
    ) async throws -> ShopperSessionWithAppSwitchEligibility
}

@_documentation(visibility: private)
public class CreateShopperSessionAPI: CreateShopperSessionAPIProtocol {

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient
    private let authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
        self.authenticationSecureTokenServiceAPI = AuthenticationSecureTokenServiceAPI(coreConfig: coreConfig)
    }

    init(
        coreConfig: CoreConfig,
        networkingClient: NetworkingClient,
        authenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI
    ) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
        self.authenticationSecureTokenServiceAPI = authenticationSecureTokenServiceAPI
    }

    func createShopperSessionForCheckout(
        request: PayPalWebCheckoutRequest,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool
    ) async throws -> ShopperSessionWithAppSwitchEligibility {
        try await createShopperSession(
            userIdentity: request.userIdentity,
            urlConfig: request.urlConfig,
            flowType: PayPalCoreConstants.flowTypeOneTimePayment,
            userAction: try PayPalUserActionGraphQL.checkoutValue(for: request.userAction),
            paypalAppInstalled: paypalAppInstalled,
            venmoAppInstalled: venmoAppInstalled
        )
    }

    func createShopperSessionForVault(
        request: PayPalVaultRequest,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool
    ) async throws -> ShopperSessionWithAppSwitchEligibility {
        try await createShopperSession(
            userIdentity: request.userIdentity,
            urlConfig: request.urlConfig,
            flowType: PayPalCoreConstants.flowTypeBillingWithoutPurchase,
            userAction: PayPalUserActionGraphQL.vaultValue(for: request.userAction),
            paypalAppInstalled: paypalAppInstalled,
            venmoAppInstalled: venmoAppInstalled
        )
    }

    private func createShopperSession(
        userIdentity: PayPalUserIdentity?,
        urlConfig: PayPalURLConfig,
        flowType: String,
        userAction: String,
        paypalAppInstalled: Bool,
        venmoAppInstalled: Bool
    ) async throws -> ShopperSessionWithAppSwitchEligibility {
        let lsat = try await authenticationSecureTokenServiceAPI.createLowScopedAccessToken().accessToken

        let input = CreateShopperSessionWithAppSwitchEligibilityInput.make(
            config: coreConfig,
            sdkVersion: PayPalCoreConstants.payPalSDKVersion,
            osVersion: UIDevice.current.systemVersion,
            paymentMethod: PayPalCoreConstants.paymentMethodPayPal,
            flowType: flowType,
            paypalAppInstalled: paypalAppInstalled,
            venmoAppInstalled: venmoAppInstalled,
            userIdentity: userIdentity,
            urlConfig: urlConfig,
            userAction: userAction
        )

        let graphQLRequest = GraphQLRequest(
            query: ShopperSessionGraphQLQueries.createShopperSessionWithAppSwitchEligibility,
            variables: CreateShopperSessionGraphQLVariables(input: input),
            queryNameForURL: nil
        )

        let httpResponse = try await networkingClient.fetch(
            request: graphQLRequest,
            additionalHeaders: [.authorization: "Bearer \(lsat)"]
        )

        let parsed = try HTTPResponseParser().parseGraphQL(
            httpResponse,
            as: CreateShopperSessionResponse.self
        )

        guard let session = parsed.createShopperSessionWithAppSwitchEligibility else {
            throw NetworkingError.noGraphQLDataKey
        }

        return session
    }
}
