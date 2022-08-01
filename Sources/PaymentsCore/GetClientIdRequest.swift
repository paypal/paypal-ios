import Foundation

struct GetClientIdRequest: APIRequest {

    typealias ResponseType = GetClientIdResponse

    let path: String = "v1/oauth2/token"
    let token: String
    var method: HTTPMethod = .get
    var body: Data?

    var headers: [HTTPHeader: String] {
        return [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer \(token)"
        ]
    }

    /// Creates request to get the order information
    init(token: String) {
        self.token = token
    }
}
