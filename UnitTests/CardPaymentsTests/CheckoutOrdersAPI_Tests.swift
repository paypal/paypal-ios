import Foundation
import XCTest
@testable import CardPayments
@testable import CorePayments
@testable import TestShared

class CheckoutOrdersAPI_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    var sut: CheckoutOrdersAPI!
    var mockAPIClient: MockAPIClient!
    let coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    let stubHTTPResponse = HTTPResponse(status: 200, body: nil)
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        
        let mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockAPIClient = MockAPIClient(http: mockHTTP)
        mockAPIClient.stubHTTPResponse = stubHTTPResponse
        sut = CheckoutOrdersAPI(coreConfig: coreConfig, apiClient: mockAPIClient)
    }
    
    // MARK: - confirmPaymentSource()
    
    func testConfirmPaymentSource_constructsRESTRequestForV2CheckoutOrders() async {
        let fakeCardRequest = CardRequest(
            orderID: "my-order-id",
            card: Card(
                number: "4111",
                expirationMonth: "01",
                expirationYear: "1234",
                securityCode: "123"
            )
        )
        
        _ = try? await sut.confirmPaymentSource(cardRequest: fakeCardRequest)
        
        XCTAssertEqual(mockAPIClient.capturedRESTRequest?.path, "/v2/checkout/orders/my-order-id/confirm-payment-source")
        XCTAssertEqual(mockAPIClient.capturedRESTRequest?.method, .post)
        XCTAssertEqual(mockAPIClient.capturedRESTRequest?.queryParameters, nil)
        
        let postBody = mockAPIClient.capturedRESTRequest?.postParameters as! ConfirmPaymentSourceRequest
        XCTAssertEqual(postBody.returnURL, "sdk.ios.paypal://card/success")
        XCTAssertEqual(postBody.cancelURL, "sdk.ios.paypal://card/cancel")
        XCTAssertEqual(postBody.cardRequest.orderID, "my-order-id")
        XCTAssertEqual(postBody.cardRequest.card.number, "4111")
        XCTAssertEqual(postBody.cardRequest.card.expirationMonth, "01")
        XCTAssertEqual(postBody.cardRequest.card.expirationYear, "1234")
        XCTAssertEqual(postBody.cardRequest.card.securityCode, "123")
    }
    
    // calls apiClient with expected RESTRequest details
    
    // bubbles error from apiClient.fetch call if happens
    
    // returns parsedConfirmPaymentSource
    
    // bubbles parsing Error from responseParser
}
