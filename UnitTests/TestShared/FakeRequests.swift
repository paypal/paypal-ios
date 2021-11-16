import Foundation
import PaymentsCore

public struct FakeResponse: Codable {

    var fakeParam: String
}

class FakeRequest: APIRequest {

    typealias ResponseType = FakeResponse

    public var path = "/fake-path"
    public var method = HTTPMethod.post
    public var body: Data?
    public var headers = [HTTPHeader.accept: "test-header"]

    func toURLRequest(environment: Environment) -> URLRequest? {
        composeURLRequest(environment: environment)
    }
}

class FakeRequestNoURL: FakeRequest {

    override func toURLRequest(environment: Environment) -> URLRequest? {
        return nil
    }
}
