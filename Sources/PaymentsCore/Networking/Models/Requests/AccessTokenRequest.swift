import Foundation

/// Describes request to get a low scoped access token (LSAT) given some Client ID
public struct AccessTokenRequest: APIRequest {
    public typealias ResponseType = AccessTokenResponse

    public var clientID: String

    public var path: String = "/v1/oauth2/token"
    public var method: HTTPMethod = .post
    public var body: Data? = "grant_type=client_credentials".data(using: .utf8)

    public var headers: [HTTPHeader: String] {
        let encodedClientID = "\(clientID):".data(using: .utf8)?.base64EncodedString() ?? ""
        return [
            .accept: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Basic \(encodedClientID)"
        ]
    }

    public init(clientID: String) {
        self.clientID = clientID
    }
}
