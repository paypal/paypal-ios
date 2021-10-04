import XCTest
@testable import PaymentsCore

class APIClient_Tests: XCTestCase {

    lazy var apiClient: APIClient = {
        APIClient(
            urlSession: URLSession(urlProtocol: URLProtocolMock.self),
            environment: .sandbox
        )
    }()

    func testFetch_withAccessTokenSuccessMockResponse_vendsValidAccessToken() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockSuccessResponse: String = """
        {
            "scope": "fake-scope",
            "access_token": "fake-token",
            "token_type": "fake-bearer",
            "expires_in": 1,
            "nonce": "fake-nonce"
        }
        """

        let mockRequestResponse = RequestResponseMock(
            request: AccessTokenRequest(clientID: ""),
            statusCode: 200,
            responseString: mockSuccessResponse
        )

        URLProtocolMock.requestResponses.append(mockRequestResponse)

        apiClient.fetch(endpoint: mockRequestResponse) { result, _ in
            guard case .success(let response) = result else {
                XCTFail("Expect success response")
                return
            }

            XCTAssertEqual(response.accessToken, "fake-token")
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withAccessTokenFailureMockResponse_vendsUnknownError() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockFailureResponse: String = """
        {
            "error": "unsupported_grant_type",
            "error_description": "unsupported grant_type"
        }
        """

        let mockRequestResponse = RequestResponseMock(
            request: AccessTokenRequest(clientID: ""),
            statusCode: 404,
            responseString: mockFailureResponse
        )

        URLProtocolMock.requestResponses.append(mockRequestResponse)

        apiClient.fetch(endpoint: mockRequestResponse) { result, _ in
            guard case .failure(.unknown) = result else {
                XCTFail("Expect NetworkingError.unknown for status code 404")
                return
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withAccessTokenInvalidMockResponse_vendsDecodingError() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockInvalidResponse: String = """
        {
            "test": "wrong response format"
        }
        """

        let mockRequestResponse = RequestResponseMock(
            request: AccessTokenRequest(clientID: ""),
            statusCode: 200,
            responseString: mockInvalidResponse
        )

        URLProtocolMock.requestResponses.append(mockRequestResponse)

        apiClient.fetch(endpoint: mockRequestResponse) { result, _ in
            guard case .failure(.parsingError) = result else {
                XCTFail("Expect NetworkingError.decodingError for invalid response")
                return
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withRequestExpectingEmptyResponse_vendsSuccessResult() {
        let expect = expectation(description: "Get empty response type for mock request")
        let emptyRequest = EmptyRequestResponseMock()

        URLProtocolMock.requestResponses.append(emptyRequest)

        apiClient.fetch(endpoint: emptyRequest) { result, _ in
            guard case .success = result else {
                XCTFail("Expected successful empty response")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withServerError_vendsConnectionIssueError() {
        let expect = expectation(description: "should vend error to client call site")
        let serverError = NSError(
            domain: URLError.errorDomain,
            code: NSURLErrorBadServerResponse,
            userInfo: nil
        )

        let mockRequest = RequestResponseMock(
            request: AccessTokenRequest(clientID: "123"),
            statusCode: 400,
            error: serverError
        )

        URLProtocolMock.requestResponses.append(mockRequest)

        apiClient.fetch(endpoint: mockRequest) { result, _ in
            guard case .failure(.connectionIssue) = result else {
                XCTFail("Should receive a networking error response")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withNoResponseMock_vendsNoReponseError() {
        let expect = expectation(description: "Should receive bad URLResponse error")
        let noReponseRequest = NoReponseRequestMock()

        URLProtocolMock.requestResponses.append(noReponseRequest)

        apiClient.fetch(endpoint: noReponseRequest) { result, _ in
            guard case .failure(.invalidURLResponse) = result else {
                XCTFail("Expected bad URLResponse error")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withNoURLRequest_vendsNoURLRequestError() {
        let expect = expectation(description: "Should receive noURLRequest error")

        // Mock request whose API object does not vend a URLRequest
        let noURLRequest = NoURLRequestMock()

        URLProtocolMock.requestResponses.append(noURLRequest)

        apiClient.fetch(endpoint: noURLRequest) { result, _ in
            guard case .failure(.noURLRequest) = result else {
                XCTFail("Expected bad URLResponse error")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

}
