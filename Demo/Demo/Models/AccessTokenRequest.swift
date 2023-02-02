import Foundation
import CorePayments

/// Describes request to get a low scoped access token (LSAT) given some Client ID
public struct AccessTokenRequest: APIRequest {

    public typealias ResponseType = AccessTokenResponse

    public var path: String = "/access_tokens"
    public var method: HTTPMethod = .post
    public var body: Data?

    public var headers: [HTTPHeader: String] {
        [
            .accept: "application/json",
            .acceptLanguage: "en_US"
        ]
    }
}
