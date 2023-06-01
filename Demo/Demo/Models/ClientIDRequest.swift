import Foundation
import CorePayments

public struct ClientIDRequest: APIRequest {

    public typealias ResponseType = ClientIDResponse

    public var path: String = "/client_id"
    public var method: HTTPMethod = .get
    public var body: Data?

    public var headers: [HTTPHeader: String] {
        [
            .accept: "application/json",
            .acceptLanguage: "en_US"
        ]
    }
}
