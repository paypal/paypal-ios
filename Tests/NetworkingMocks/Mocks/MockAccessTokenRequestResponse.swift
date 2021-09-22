import Foundation

class MockAccessTokenRequestResponse: MockResponse {

    var responseString: String?
    var statusCode: Int
    let responseError: Error?

    var responseData: Data? {
        return responseString?.data(using: .utf8)
    }

    init(responseString: String?, statusCode: Int, error: Error? = nil) {
        self.responseString = responseString
        self.statusCode = statusCode
        self.responseError = error
    }

    func canHandle(request: URLRequest) -> Bool {
        request.url?.path == "/v1/oauth2/token"
    }

    func response(for request: URLRequest) -> HTTPURLResponse? {
        guard let url = request.url else {
            return nil
        }
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:])
    }
}
