import Foundation

/// This class coordinates networking logic for communicating with the /graphql?UpdateClientConfig API.
@_documentation(visibility: private)
public class UpdateClientConfigAPI {

    // MARK: - Private Properties

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient

    // MARK: - Initializer

    public init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }

    /// Exposed for injecting MockNetworkingClient in tests
    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }

    // MARK: - Internal Methods

    public func updateClientConfig(token: String, fundingSource: String) async throws -> ClientConfigResponse {

        let queryString = """
            mutation UpdateClientConfig(
                $token: String!,
                $fundingSource: ButtonFundingSourceType!,
                $integrationArtifact: IntegrationArtifactType!,
                $userExperienceFlow: UserExperienceFlowType!,
                $productFlow: ProductFlowType!,
                $channel: ProductChannel!
            ) {
                updateClientConfig(
                    token: $token
                    fundingSource: $fundingSource
                    integrationArtifact: $integrationArtifact,
                    userExperienceFlow: $userExperienceFlow,
                    productFlow: $productFlow,
                    channel: $channel
                )
            }
        """

        let variables = UpdateClientConfigVariables(
            token: token,
            fundingSource: fundingSource,
            integrationArtifact: "MOBILE_SDK",
            userExperienceFlow: "INCONTEXT",
            productFlow: "HERMES",
            channel: "MOBILE_APP"
        )

        let graphQLRequest = GraphQLRequest(
            query: queryString,
            variables: variables,
            queryNameForURL: "UpdateClientConfig"
        )

        let httpResponse = try await networkingClient.fetch(request: graphQLRequest, clientContext: token)
        
        #if DEBUG
        print("HTTP Response Status: \(httpResponse.status)")
        if let bodyData = httpResponse.body, let responseBody = String(data: bodyData, encoding: .utf8) {
            print("HTTP Response Body: \(responseBody)")
        } else {
            print("HTTP Response Body: (error - could not parse)")
        }
        #endif
        
        return try HTTPResponseParser().parseGraphQL(httpResponse, as: ClientConfigResponse.self)
    }
}
