import Foundation

struct AccessTokenRequest: APIRequest {
    var path: String = "/v1/oauth2/token"
    var method: HTTPMethod = .post
    var headers: [HTTPHeader: String] {
        let encodedClientID = "\(clientID):".data(using: .utf8)?.base64EncodedString() ?? ""

        return [
            .accept: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Basic \(encodedClientID)"
        ]
    }

    var body: Data = "grant_type=client_credentials".data(using: .utf8)!

    var clientID: String

    init(clientID: String) {
        self.clientID = clientID
    }
}
