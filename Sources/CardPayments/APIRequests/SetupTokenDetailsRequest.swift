import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

struct SetupTokenDetailsRequest: APIRequest {
    
    private let pathFormat: String = "/v3/vault/setup-tokens/%@"
    private let base64EncodedCredentials: String
    var jsonEncoder: JSONEncoder
    
    init(
        clientID: String,
        setupTokenID: String,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        self.jsonEncoder = encoder
        self.base64EncodedCredentials = Data(clientID.appending(":").utf8).base64EncodedString()
        path = String(format: pathFormat, setupTokenID)
    }
    
    // MARK: - APIRequest
    
    typealias ResponseType = SetupTokenDetailsResponse
    
    var path: String
    var method: HTTPMethod = .get
    var body: Data?
    
    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json", .acceptLanguage: "en_US",
            .authorization: "Basic \(base64EncodedCredentials)"
        ]
    }
}
