import Foundation
import PaymentsCore

class EmptyRequestResponseMock: RequestResponseMock<EmptyResponse> {

    init(path: String = "/mock/path") {
        super.init(responseType: EmptyResponse.self, path: path)
    }

    override func toURLRequest(environment: Environment) -> URLRequest? {
        super.toURLRequest(environment: environment)
    }
}

class NoReponseRequestMock: EmptyRequestResponseMock {
    override func response(for request: URLRequest) -> HTTPURLResponse? {
        return nil
    }
}

class NoURLRequestMock: EmptyRequestResponseMock {
    override func toURLRequest(environment: Environment) -> URLRequest? {
        return nil
    }
}
