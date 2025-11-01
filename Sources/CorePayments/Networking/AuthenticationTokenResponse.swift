import Foundation

@_documentation(visibility: private)
public struct AuthTokenResponse: Decodable {

    let accessToken: String
    let tokenType: String
}
