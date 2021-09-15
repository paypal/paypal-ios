import Foundation

public class AccessTokenResponse: Codable {
    var scope: String
    var accessToken: String
    var tokenType: String
    var expiresIn: Int
    var nonce: String

    enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case nonce
    }
}
