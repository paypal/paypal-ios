import Foundation
@testable import CorePayments

class MockQuededURLSession: URLSessionProtocol {

    private var quededResponses: [MockResponse] = []

    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if quededResponses.isEmpty {
            fatalError("No responses found")
        }
        if let response = quededResponses.first {
            quededResponses.remove(at: 0)
            switch response {
            case .success(let success):
                return (success.data, success.urlResponse)

            case .failure(let error):
                throw error
            }
        } else {
            fatalError("Response can not be null")
        }
    }

    func addResponse(_ response: MockResponse) {
        quededResponses.append(response)
    }

    func clear() {
        quededResponses.removeAll()
    }
}

enum MockResponse {

    struct Success {

        let data: Data
        let urlResponse: URLResponse
    }

    case success(Success)
    case failure(Error)
}
