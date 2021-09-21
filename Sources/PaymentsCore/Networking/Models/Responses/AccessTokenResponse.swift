
public struct AccessTokenResponse: Codable {
    let scope: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let nonce: String

    enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case nonce
    }
}
