import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// This class coordinates networking logic for communicating with the /graphql?UpdateClientConfig API.
class UpdateClientConfigAPI {

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient

    // MARK: - Initializer

    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }

    /// Exposed for injecting MockNetworkingClient in tests
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }

    // MARK: - Internal Methods

    func updateClientConfig(request: PayPalWebCheckoutRequest) async throws -> ClientConfigResponse {

        let queryString = """
            mutation UpdateClientConfig(
                $orderID: String!,
                $fundingSource: ButtonFundingSourceType!,
                $integrationArtifact: IntegrationArtifactType!,
                $userExperienceFlow: UserExperienceFlowType!,
                $productFlow: ProductFlowType!,
                $buttonSessionID: String
            ) {
                updateClientConfig(
                    token: $orderID
                    fundingSource: $fundingSource
                    integrationArtifact: $integrationArtifact,
                    userExperienceFlow: $userExperienceFlow,
                    productFlow: $productFlow,
                    buttonSessionID: $buttonSessionID
                )
            }
        """

        let variables = UpdateClientConfigVariables(
            orderID: request.orderID,
            fundingSource: request.fundingSource.rawValue,
            integrationArtifact: "PAYPAL_JS_SDK", // PAYPAL_JS_SDK or NATIVE_SDK
            userExperienceFlow: "INCONTEXT", // INCONTEXT or INLINE
            productFlow: "SMART_PAYMENT_BUTTONS", // NATIVE or SMART_PAYMENT_BUTTONS
            buttonSessionID: nil
        )

        let graphQLRequest = GraphQLRequest(
            query: queryString,
            variables: variables,
            queryNameForURL: "UpdateClientConfig"
        )

        let httpResponse = try await networkingClient.fetch(request: graphQLRequest, clientContext: request.orderID)

        // to grab correlationId
        let dataDict = try HTTPResponseParser().parseGraphQLDictionary(httpResponse)
        print("full graphQL response: \(dataDict)")

        return try HTTPResponseParser().parseGraphQL(httpResponse, as: ClientConfigResponse.self)
    }
}
