import Foundation

struct GetClientIDRequest: APIRequest {
    
    private let accessToken: String
    
    /// Creates request to get the order information
    init(accessToken: String) {
        self.accessToken = accessToken
    }

    // MARK: - APIRequest

    typealias ResponseType = GetClientIDResponse

    let path: String = "v1/oauth2/token"
    var method: HTTPMethod = .get

    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer \(accessToken)"
        ]
    }
}
