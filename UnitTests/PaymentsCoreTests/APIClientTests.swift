import XCTest
@testable import PaymentsCore

class APIClientTests: XCTestCase {

    func testFetchRequest() {
        let expect = expectation(description: "Expect fetch request to execute")

        let apiClient: APIClient = APIClient()

        apiClient.fetch(
            endpoint: Request(clientID: "Adsm9w5M-BRDJdimEQAT0m5q2iXUnmnefVTQ6Vm3MmO4Izbyz76QEI3WmaFb0kRQPaPCxFkosJIrFADE")
        ) { (result: Result<AccessTokenRespose, Error>) in
                switch result {
                case .success(let response):
                    XCTAssertNotNil(response.access_token)
                    expect.fulfill()
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }
        waitForExpectations(timeout: 10)
    }
}

class AccessTokenRespose: Codable {
    var scope: String
    var access_token: String
    var token_type: String
    var expires_in: Int
    var nonce: String
}

struct Request: APIRequest {
    var path: String = "/v1/oauth2/token"
    var method: HTTPMethod = .post
    var headers: [HTTPHeader: String] {
        let encodedClientID = "\(clientID):".data(using: .utf8)?.base64EncodedString() ?? ""

        return [
            .accept: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Basic \(encodedClientID)"
        ]
    }

    var queryParameters: [String : String] = [:]
    var body: Data = "grant_type=client_credentials".data(using: .utf8)!
    var urlRequest: URLRequest? {
        let environment: Environment = .sandbox
        var request = URLRequest(url: environment.baseURL.appendingPathComponent(path))
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key.rawValue)
        }
        request.httpMethod = method.rawValue
        request.httpBody = body

        return request
    }

    var clientID: String

    init(clientID: String) {
        self.clientID = clientID
    }
}
