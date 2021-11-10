// swiftlint:disable space_after_main_type

public struct AccessTokenResponse: Codable {
    let scope: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let nonce: String
}
