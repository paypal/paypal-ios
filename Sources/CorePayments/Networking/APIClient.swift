import Foundation

/// :nodoc: This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// `APIClient` is the entry point for each payment method feature to perform API requests. It also offers convenience methods for API requests used across multiple payment methods / modules.
public class APIClient {
        
    // MARK: - Internal Properties
    
    private var http: HTTP
    private let coreConfig: CoreConfig
    
    // MARK: - Public Initializer

    public init(coreConfig: CoreConfig) {
        self.http = HTTP(coreConfig: coreConfig)
        self.coreConfig = coreConfig
    }
    
    // MARK: - Internal Initializer

    /// Exposed for testing
    init(http: HTTP) {
        self.http = http
        self.coreConfig = http.coreConfig
    }
    
    // MARK: - Public Methods
    
    /// :nodoc:
    public func fetch(request: RESTRequest) async throws -> HTTPResponse {
        let url = try constructURL(path: request.path, queryParameters: request.queryParameters ?? [:]) // cleaner way
        
        let httpRequest = HTTPRequest(
            url: url,
            method: request.method,
            body: request.body,
            headers: request.headers
        )
        
        return try await http.performRequest(httpRequest)
    }
    
    // TODO: - Add GraphQL equivalent request type & function
//     public func fetch(request: GraphQLRequest) async throws -> HTTPResponse { }
    public func fetch() throws {
        let queryString = """
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
                        rel, href
                    }
                }
            }
        """
        
        // TODO: - Move JSON encoding into custom class, similar to HTTPResponseParser
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let variables = try encoder.encode(VaultDataEncodableVariables())
        
        // Combine varialbes & query into single post body
        let graphQLRequest = GraphQLRequest(
            queryNameForURL: "UpdateVaultSetupToken",
            query: queryString,
            variables: variables
        )
        
        // Construct HTTPRequest
    }
    
    // MARK: - Private Methods
    
    private func constructURL(path: String, queryParameters: [String: String]) throws -> URL {
        let urlString = coreConfig.environment.baseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(url: urlString, resolvingAgainstBaseURL: false)
        
        queryParameters.forEach {
            urlComponents?.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        guard let url = urlComponents?.url else {
            throw CorePaymentsError.clientIDNotFoundError // TODO: - throw proper error type
        }
        
        return url
    }
}

/// :nodoc:
public struct GraphQLRequest {
    let queryNameForURL: String?
    let query: String
    let variables: Data // Dictionary
}

struct VaultDataEncodableVariables: Encodable {
    
    // MARK: - Coding KEys
    
    private enum TopLevelKeys: String, CodingKey {
        case clientID
        case vaultSetupToken
        case paymentSource
    }
    
    private  enum PaymentSourceKeys: String, CodingKey {
        case card
    }
    
    private enum CardKeys: String, CodingKey {
        case number
        case securityCode
        case expiry
        case name
    }
    
    // MARK: - Initializer
    
    // TODO: - Migrate details from VaultRequest introduced in Victoria's PR
    
    // MARK: - Custom Encoder
    
    func encode(to encoder: Encoder) throws {
        var topLevel = encoder.container(keyedBy: TopLevelKeys.self)
        try topLevel.encode("fake-client-id", forKey: .clientID)
        try topLevel.encode("fake-vault-setup-token", forKey: .vaultSetupToken)
        
        var paymentSource = topLevel.nestedContainer(keyedBy: PaymentSourceKeys.self, forKey: .paymentSource)
        
        var card = paymentSource.nestedContainer(keyedBy: CardKeys.self, forKey: .card)
        try card.encode("4111 1111 1111 1111", forKey: .number)
        try card.encode("123", forKey: .securityCode)
        try card.encode("2027-09", forKey: .expiry)
        try card.encode("Sammy", forKey: .name)
    }
}

// SAMPLE
//{
//  "query": "query GreetingQuery ($arg1: String) { hello (name: $arg1) { value } }",
//  "operationName": "GreetingQuery",
//  "variables": { "arg1": "Timothy" }
//}
