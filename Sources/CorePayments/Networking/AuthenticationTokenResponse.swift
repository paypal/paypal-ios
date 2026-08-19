import Foundation

@_documentation(visibility: private)
public struct AuthTokenResponse: Decodable {

    public let accessToken: String
    let tokenType: String
}
