import Foundation

class URLProtocolMock: URLProtocol {
    // MARK: - Errors

    private enum Errors: String, Error {
        case noResponse = "no_response_to_match"
    }

    // MARK: - Variables

    /// The list of mock request/response that URLProtocol will process
    static var requestResponses: [ResponseMock] = []

    // MARK: - Override URLProtocol Functions

    override class func canInit(with request: URLRequest) -> Bool {
        // Determine if URLProtocolMock should process this request
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Returns a canonical version of the request if needed, otherwise returns the request
        request
    }

    override func startLoading() {
        // Start processing a request
        guard let client = client else { return }

        // Here we try to match the request to the proper ResponseMock otherwise don't
        guard
            let firstIndex = Self.requestResponses
                .firstIndex(where: { $0.canHandle(request: request) })
        else {
            client.urlProtocol(
                self,
                didFailWithError: Errors.noResponse
            )
            client.urlProtocolDidFinishLoading(self)
            return
        }

        // If there is a mock response for the request, pop it from requestResponses and vend mock response
        let requestResponse = Self.requestResponses.remove(at: firstIndex)
        resolveRequest(with: requestResponse, client: client)
    }

    override func stopLoading() {
        // URLProtocolMock has finished processing the request. No-op.
    }

    // MARK: - Private Functions

    private func resolveRequest(
        with requestResponse: ResponseMock,
        client: URLProtocolClient
    ) {
        if let response = requestResponse.response(for: request) {
            client.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
        }

        if let data = requestResponse.responseData {
            client.urlProtocol(
                self,
                didLoad: data
            )
        } else if let error = requestResponse.responseError {
            client.urlProtocol(
                self,
                didFailWithError: error
            )
        }

        client.urlProtocolDidFinishLoading(self)
    }
}
