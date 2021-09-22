import XCTest
@testable import PaymentsCore

class APIClient_Tests: XCTestCase {

    lazy var apiClient: APIClient = {
        APIClient(
            urlSession: URLSession(urlProtocol: URLProtocolMock.self),
            environment: .sandbox
        )
    }()

    func testFetch_withAccessTokenSuccessMockResponse_returnsValidAccessToken() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockSuccessResponse: String = """
        {
            "scope": "https://uri.paypal.com/services/invoicing",
            "access_token": "TestToken",
            "token_type": "Bearer",
            "expires_in": 29688,
            "nonce": "2021-09-13T15:00:23ZLpaHBzwLdATlXfE-G4NJsoxi9jPsYuMzOIE4u1TqDx8"
        }
        """

        let mockRequestResponse = MockRequestResponse(
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

            XCTAssertEqual(response.accessToken, "TestToken")
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

        let mockRequestResponse = MockRequestResponse(
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

    func testFetch_withAccessTokenInvalidMockResponse_returnsDecodingError() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockInvalidResponse: String = """
        {
            "test": "wrong response format"
        }
        """

        let mockRequestResponse = MockRequestResponse(
            request: AccessTokenRequest(clientID: ""),
            statusCode: 200,
            responseString: mockInvalidResponse
        )

        URLProtocolMock.requestResponses.append(mockRequestResponse)

        apiClient.fetch(endpoint: mockRequestResponse) { result, _ in
            guard case .failure(.decodingError) = result else {
                XCTFail("Expect NetworkingError.decodingError for invalid response")
                return
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withEmptyResponse_vendsSuccessfully() {
        let expect = expectation(description: "Get empty response type for mock request")
        let emptyRequest = MockEmptyRequestResponse()

        URLProtocolMock.requestResponses.append(emptyRequest)

        apiClient.fetch(endpoint: emptyRequest) { result, _ in
            guard case .success(_) = result else {
                XCTFail("Expected successful empty response")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_withError_failsSuccessfully() {
        let expect = expectation(description: "should vend error to client call site")
        let serverError = NSError(
            domain: URLError.errorDomain,
            code: NSURLErrorBadServerResponse,
            userInfo: nil
        )

        let mockRequest = MockRequestResponse(
            request: AccessTokenRequest(clientID: "123"),
            statusCode: 400,
            error: serverError
        )

        URLProtocolMock.requestResponses.append(mockRequest)

        apiClient.fetch(endpoint: mockRequest) { result, _ in
            guard case .failure(.networkingError) = result else {
                XCTFail("Should receive a networking error response")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_noResponse_vendsNoReponseError() {
        let expect = expectation(description: "Should receive bad URLResponse error")
        let noReponseRequest = MockNoReponseRequest()

        URLProtocolMock.requestResponses.append(noReponseRequest)

        apiClient.fetch(endpoint: noReponseRequest) { result, _ in
            guard case .failure(.badURLResponse) = result else {
                XCTFail("Expected bad URLResponse error")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetch_noURLRequest_vendsNoURLRequestError() {
        let expect = expectation(description: "Should receive noURLRequest error")

        // Mock request whose API object does not vend a URLRequest
        let noURLRequest = MockNoURLRequest()

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

    func testParseDataObject_withNilData_throwsEmptyDataError() throws {
        XCTAssertThrowsError(
            try apiClient.parseDataObject(nil, type: AccessTokenRequest.self)
        ) { error in
            guard case NetworkingError.noResponseData = error else {
                XCTFail("Expected `NetworkingError.noResponseData`")
                return
            }
        }
    }
}
