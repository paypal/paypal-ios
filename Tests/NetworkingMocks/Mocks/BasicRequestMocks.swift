import Foundation
import PaymentsCore

class MockEmptyRequestResponse: MockRequestResponse<EmptyResponse> {
    init(path: String = "/mock/path") {
        super.init(responseType: EmptyResponse.self, path: path)
    }

    override func toURLRequest(environment: Environment) -> URLRequest? {
        super.toURLRequest(environment: environment)
    }
}

class MockNoReponseRequest: MockEmptyRequestResponse {
    override func response(for request: URLRequest) -> HTTPURLResponse? {
        return nil
    }
}

class MockNoURLRequest: MockEmptyRequestResponse {
    override func toURLRequest(environment: Environment) -> URLRequest? {
        return nil
    }
}
