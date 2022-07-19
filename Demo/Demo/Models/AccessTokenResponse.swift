public struct AccessTokenResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }

    let accessToken: String
}
