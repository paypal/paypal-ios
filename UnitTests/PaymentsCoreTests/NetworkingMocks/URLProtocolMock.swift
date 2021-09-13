import Foundation

class URLProtocolMock: URLProtocol {
    // MARK: - Errors

    private enum Errors: String, Error {
        case noResponse = "no_response_to_match"
        case noData = "data_is_nil"
    }

    // MARK: - Variables

    static var requestResponses: [MockRequestResponse] = []

    // MARK: - Override URLProtocol Functions

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let client = client else { return }

        // Here we try to match the request to the proper MockRequestResponse otherwise don't
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
        let requestResponse = Self.requestResponses.remove(at: firstIndex)
        resolveRequest(with: requestResponse, client: client)
    }

    override func stopLoading() {
        // no-op
    }

    // MARK: - Private Functions

    private func resolveRequest(
      with requestResponse: MockRequestResponse,
      client: URLProtocolClient
    ) {
      client.urlProtocol(
        self,
        didReceive: requestResponse.response(for: request),
        cacheStoragePolicy: .notAllowed
      )

      if let data = requestResponse.responseData {
        client.urlProtocol(
          self,
          didLoad: data
        )
      }
      else {
        client.urlProtocol(
          self,
          didFailWithError: Errors.noData
        )
      }

      client.urlProtocolDidFinishLoading(self)
    }
}
