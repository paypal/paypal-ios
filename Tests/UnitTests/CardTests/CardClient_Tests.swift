import XCTest
@testable import PaymentsCore
@testable import Card

final class CardClient_Tests: XCTestCase {

    lazy var cardClient: CardClient = {
        let config = CoreConfig(clientID: "", environment: .sandbox)
        let apiClient = APIClient(
            urlSession: URLSession(urlProtocol: URLProtocolMock.self),
            environment: .sandbox
        )
        return CardClient(config: config, apiClient: apiClient)
    }()

    func testApproveCardOrder_withCardSuccessMockResponse_returnsValidOrderData() throws {
        let expect = expectation(description: "Get success mock response")

        let mockSuccessResponse: String = """
        {
            "id": "testOrderID",
            "status": "APPROVED",
            "payment_source": {
                "card": {
                    "last_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT"
                }
            }
        }
        """

        let card = Card(number: "", expiry: CardExpiry(month: 1, year: 2021), securityCode: "")
        try setupConfirmCardPaymentSourceMock(card: card, mockResponse: mockSuccessResponse, statusCode: 200)

        cardClient.approveOrder(orderID: "", card: card) { result in
            guard case .success(let orderData) = result else {
                XCTFail("Expect success response")
                return
            }

            XCTAssertEqual(orderData.orderID, "testOrderID")
            XCTAssertEqual(orderData.status, .approved)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testApproveCardOrder_withCardFailureMockResponse_returnsError() throws {
        let expect = expectation(description: "Get success mock response")

        let mockFailureResponse: String = """
        {
            "name": "RESOURCE_NOT_FOUND",
            "details": [
                {
                    "issue": "INVALID_RESOURCE_ID",
                    "description": "Specified resource ID does not exist. Please check the resource ID and try again."
                }
            ],
            "message": "The specified resource does not exist.",
            "debug_id": "81db5c4ddfa35"
        }
        """

        let card = Card(number: "", expiry: CardExpiry(month: 1, year: 2021), securityCode: "")
        try setupConfirmCardPaymentSourceMock(card: card, mockResponse: mockFailureResponse, statusCode: 404)

        cardClient.approveOrder(orderID: "", card: card) { result in
            guard case .failure(NetworkingError.unknown) = result else {
                XCTFail("Expect NetworkingError.unknown for status code 404")
                return
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testApproveCardOrder_withInvalidFormatMockResponse_returnsError() throws {
        let expect = expectation(description: "Get success mock response")

        let mockInvalidResponse: String = """
        {
            "some_unexpected_response": "something"
        }
        """

        let card = Card(number: "", expiry: CardExpiry(month: 1, year: 2021), securityCode: "")
        try setupConfirmCardPaymentSourceMock(card: card, mockResponse: mockInvalidResponse, statusCode: 200)

        cardClient.approveOrder(orderID: "", card: card) { result in
            guard case .failure(NetworkingError.parsingError) = result else {
                XCTFail("Expect NetworkingError.parsingError for invalid response")
                return
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    private func setupConfirmCardPaymentSourceMock(card: Card, mockResponse: String, statusCode: Int) throws {
        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(
                paymentSource: card,
                orderID: "",
                clientID: ""
            )
        )
        let mockRequestResponse = RequestResponseMock(
            request: confirmPaymentSourceRequest,
            statusCode: statusCode,
            responseString: mockResponse
        )

        URLProtocolMock.requestResponses.append(mockRequestResponse)
    }
}
