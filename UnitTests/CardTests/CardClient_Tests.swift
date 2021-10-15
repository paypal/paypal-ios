import XCTest
@testable import PaymentsCore
@testable import Card
@testable import TestShared

final class CardClient_Tests: XCTestCase {
    
    private let config = CoreConfig(clientID: "", environment: .sandbox)
    private let card = Card(number: "", expirationMonth: "01", expirationYear: "2021", securityCode: "")
    
    private var api: APIClientMock!
    private var sut: CardClient!
    
    override func setUp() {
        api = APIClientMock()
        sut = CardClient(api: api)
    }
    
    func testApproveOrder_shouldSendAnAPIRequest() {
        sut.approveOrder(orderID: "123", card: card) { _ in }
        
        let apiRequest = api.lastSentRequest!
        XCTAssertEqual("/v2/checkout/orders/123/confirm-payment-source", apiRequest.path)
        XCTAssertEqual(.post, apiRequest.method)
        
        let payload = apiRequest.body as! ConfirmPaymentSourceBody
        XCTAssertEqual(payload.paymentSource.card, card)
    }
    
    func testApproveOrder_whenSuccessful_callbackOrderData() {
        var successResponse = HttpResponse(status: 200)
        successResponse.body = """
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
        """.data(using: .utf8)
        api.stubSend(with: successResponse)
        
        let expect = expectation(description: "callback order data")
        sut.approveOrder(orderID: "123", card: card) { result in
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
    
    func testApproveOrder_whenResourceNotFound_callbackUnknownError() {
        var notFoundResponse = HttpResponse(status: 404)
        notFoundResponse.body = """
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
        """.data(using: .utf8)
        api.stubSend(with: notFoundResponse)
        
        let expect = expectation(description: "callback unknown error")
        sut.approveOrder(orderID: "123", card: card) { result in
            guard case .failure(NetworkingError.unknown) = result else {
                XCTFail("Expect NetworkingError.unknown for status code 404")
                return
            }
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testApproveOrder_whenResponseFormatIsInvalid_callbackParsingError() {
        var unexpectedResponse = HttpResponse(status: 200)
        unexpectedResponse.body = """
            {
                "some_unexpected_response": "something"
            }
        """.data(using: .utf8)
        api.stubSend(with: unexpectedResponse)
        
        let expect = expectation(description: "callback parsing error")
        sut.approveOrder(orderID: "123", card: card) { result in
            guard case .failure(NetworkingError.parsingError) = result else {
                XCTFail("Expect NetworkingError.parsingError for invalid response")
                return
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
