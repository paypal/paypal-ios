import Foundation
import XCTest
@testable import CardPayments
@testable import CorePayments
@testable import TestShared

class CheckoutOrdersAPI_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    var sut: CheckoutOrdersAPI!
    var mockNetworkingClient: MockNetworkingClient!
    let coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    let cardRequest = CardRequest(
        orderID: "my-order-id",
        card: Card(
            number: "4111",
            expirationMonth: "01",
            expirationYear: "1234",
            securityCode: "123"
        )
    )
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        
        let mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockNetworkingClient = MockNetworkingClient(http: mockHTTP)
        sut = CheckoutOrdersAPI(coreConfig: coreConfig, networkingClient: mockNetworkingClient)
    }
    
    // MARK: - confirmPaymentSource()
    
    func testConfirmPaymentSource_constructsRESTRequestForV2CheckoutOrders() async {
        _ = try? await sut.confirmPaymentSource(cardRequest: cardRequest)
        
        XCTAssertEqual(mockNetworkingClient.capturedRESTRequest?.path, "/v2/checkout/orders/my-order-id/confirm-payment-source")
        XCTAssertEqual(mockNetworkingClient.capturedRESTRequest?.method, .post)
        XCTAssertEqual(mockNetworkingClient.capturedRESTRequest?.queryParameters, nil)
        
        let postBody = mockNetworkingClient.capturedRESTRequest?.postParameters as! ConfirmPaymentSourceRequest
        XCTAssertEqual(postBody.returnURL, "sdk.ios.paypal://card/success")
        XCTAssertEqual(postBody.cancelURL, "sdk.ios.paypal://card/cancel")
        XCTAssertEqual(postBody.cardRequest.orderID, "my-order-id")
        XCTAssertEqual(postBody.cardRequest.card.number, "4111")
        XCTAssertEqual(postBody.cardRequest.card.expirationMonth, "01")
        XCTAssertEqual(postBody.cardRequest.card.expirationYear, "1234")
        XCTAssertEqual(postBody.cardRequest.card.securityCode, "123")
    }
    
    func testConfirmPaymentSource_whenNetworkingClientError_bubblesError() async {
        mockNetworkingClient.stubHTTPError = CoreSDKError(code: 123, domain: "api-client-error", errorDescription: "error-desc")
        
        do {
            _ = try await sut.confirmPaymentSource(cardRequest: cardRequest)
            XCTFail("Expected error throw.")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.domain, "api-client-error")
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "error-desc")
        }
    }
    
    func testConfirmPaymentSource_whenSuccess_returnsParsedConfirmPaymentSourceResponse() async throws {
        let successsResponseJSON = """
        {
            "id": "testOrderId",
            "status": "CREATED",
            "intent": "CAPTURE",
            "payment_source": {
                "card": {
                    "last_four_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT",
                    "authentication_result": {
                        "liability_shift": "POSSIBLE",
                            "three_d_secure": {
                                "enrollment_status": "Y",
                                "authentication_status": "Y"
                            }
                    }
                }
            },
            "links": [
                {
                    "rel": "payer-action",
                    "href": "some-url"
                }
            ]
        }
        """
        
        let data = successsResponseJSON.data(using: .utf8)
        let stubbedHTTPResponse = HTTPResponse(status: 200, body: data)
        mockNetworkingClient.stubHTTPResponse = stubbedHTTPResponse
        
        let response = try await sut.confirmPaymentSource(cardRequest: cardRequest)
        XCTAssertEqual(response.id, "testOrderId")
        XCTAssertEqual(response.status, "CREATED")
        XCTAssertEqual(response.paymentSource?.card.lastFourDigits, "7321")
        XCTAssertEqual(response.paymentSource?.card.brand, "VISA")
        XCTAssertEqual(response.paymentSource?.card.type, "CREDIT")
        XCTAssertEqual(response.paymentSource?.card.authenticationResult?.liabilityShift, "POSSIBLE")
        XCTAssertEqual(response.paymentSource?.card.authenticationResult?.threeDSecure?.enrollmentStatus, "Y")
        XCTAssertEqual(response.paymentSource?.card.authenticationResult?.threeDSecure?.authenticationStatus, "Y")
        XCTAssertEqual(response.links?.first?.rel, "payer-action")
        XCTAssertEqual(response.links?.first?.href, "some-url")
    }
}
