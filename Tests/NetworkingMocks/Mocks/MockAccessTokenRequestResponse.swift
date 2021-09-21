import Foundation

class MockAccessTokenRequestResponse: MockRequestResponse {

    var responseString: String?
    var statusCode: Int

    init(responseString: String?, statusCode: Int) {
        self.responseString = responseString
        self.statusCode = statusCode
    }

    var responseData: Data? {
        return responseString?.data(using: .utf8)
    }
    
    func canHandle(request: URLRequest) -> Bool {
        guard let url = request.url, url.path == "/v1/oauth2/token" else {
            return false
        }
        return true
    }
    
    func response(for request: URLRequest) -> HTTPURLResponse {
        guard let url = request.url else {
            fatalError("No URL for request")
        }
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:]) ?? HTTPURLResponse()
    }
}
