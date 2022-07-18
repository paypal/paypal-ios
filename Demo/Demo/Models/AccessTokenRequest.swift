import Foundation
import PaymentsCore

/// Describes request to get a low scoped access token (LSAT) given some Client ID
public struct AccessTokenRequest: APIRequest {

    public init() {
    }

    public typealias ResponseType = AccessTokenResponse

    public var path: String = "/access_tokens"
    public var method: HTTPMethod = .post
    public var body: Data?

    public var headers: [HTTPHeader: String] {
        return [
            .accept: "application/json",
            .acceptLanguage: "en_US"
        ]
    }
}
