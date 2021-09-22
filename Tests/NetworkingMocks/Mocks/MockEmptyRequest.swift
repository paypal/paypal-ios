import Foundation
import PaymentsCore

class MockRequest<Response: Codable>: APIRequest, MockRequestResponse {
    typealias ResponseType = Response

    let path: String
    let method: HTTPMethod
    let headers: [HTTPHeader: String]
    let body: Data?

    let statusCode: Int
    let responseData: Data?
    let responseError: Error?

    init<Request: APIRequest>(
        request: Request,
        statusCode: Int = 200,
        responseString: String? = nil,
        error: Error? = nil
    ) where Response == Request.ResponseType {
        self.path = request.path
        self.method = request.method
        self.headers = request.headers
        self.body = request.body
        
        self.responseData = responseString?.data(using: .utf8)
        self.responseError = error
        self.statusCode = statusCode
    }

    func canHandle(request: URLRequest) -> Bool {
        request.url?.path == path
    }

    func response(for request: URLRequest) -> HTTPURLResponse? {
        guard let url = request.url else {
            return nil
        }
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [:])
    }
}

class MockEmptyRequest: MockRequest<EmptyResponse> { }

class MockNoReponseRequest: MockEmptyRequest {
    override func response(for request: URLRequest) -> HTTPURLResponse? {
        return nil
    }
}

class MockNoURLRequest: MockEmptyRequest {
    func toURLRequest(environment: Environment) -> URLRequest? {
        return nil
    }
}
