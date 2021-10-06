import Foundation
import PaymentsCore

class MockRequestResponse<Response: Codable>: APIRequest, MockResponse {
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

        self.statusCode = statusCode
        self.responseData = responseString?.data(using: .utf8)
        self.responseError = error
    }

    init<Response: Codable>(
        responseType: Response.Type,
        path: String,
        method: HTTPMethod = .post,
        headers: [HTTPHeader: String] = [:],
        body: Data? = nil,
        statusCode: Int = 200,
        responseString: String? = nil,
        responseError: Error? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body

        self.statusCode = statusCode
        self.responseData = responseString?.data(using: .utf8)
        self.responseError = responseError
    }

    func toURLRequest(environment: Environment) -> URLRequest? {
        composeURLRequest(environment: environment)
    }

    func canHandle(request: URLRequest) -> Bool {
        request.url?.path == path
    }

    func response(for request: URLRequest) -> HTTPURLResponse? {
        guard let url = request.url else {
            return nil
        }
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:])
    }
}
