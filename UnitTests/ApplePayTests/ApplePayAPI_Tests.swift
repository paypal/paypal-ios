import XCTest
@testable import ApplePay
@testable import CorePayments
@testable import TestShared

final class ApplePayAPI_Tests: XCTestCase {

    private let configJSON =
        #"{"data":{"applepayConfig":{"isEligible":true,"merchantCountry":"US","# +
        #""merchantCapabilities":["supports3DS"],"supportedNetworks":["visa","masterCard","amex","discover"]}}}"#

    private let approvedJSON = """
    {"data":{"approveApplePayPayment":true}}
    """

    func testFetchConfig_sandbox_postsGetApplepayConfigToSandboxGraphQL() async throws {
        let (api, session) = try makeAPI(environment: .sandbox, json: configJSON)

        let config = try await api.fetchConfig(buyerCountry: nil)

        let url = try XCTUnwrap(session.capturedURLRequest?.url)
        XCTAssertEqual(url.host, "www.sandbox.paypal.com")
        XCTAssertEqual(url.path, "/graphql")
        XCTAssertEqual(url.query, "GetApplepayConfig")
        XCTAssertEqual(session.capturedURLRequest?.httpMethod, "POST")

        let body = try requestBody(session)
        XCTAssertTrue(body.query.contains("applepayConfig"))
        XCTAssertEqual(body.variables["clientId"] as? String, "client-id")
        XCTAssertEqual(body.variables["merchantId"] as? [String], ["merchant-id"])
        XCTAssertTrue(body.variables["buyerCountry"] is NSNull)
        XCTAssertEqual(config.merchantCountry, "US")
        XCTAssertEqual(config.supportedNetworks, ["visa", "masterCard", "amex", "discover"])
        XCTAssertTrue(config.isEligible)
    }

    func testConfirm_sandbox_postsApproveApplePayPaymentWithToken() async throws {
        let (api, session) = try makeAPI(environment: .sandbox, bnCode: "BN_CODE", json: approvedJSON)

        let status = try await api.confirm(orderID: "ORDER-1", authorization: sampleAuthorization(countryCode: "us"))

        let url = try XCTUnwrap(session.capturedURLRequest?.url)
        XCTAssertEqual(url.absoluteString, "https://www.sandbox.paypal.com/graphql?ApproveApplePayPayment")
        XCTAssertEqual(session.capturedURLRequest?.value(forHTTPHeaderField: "PayPal-Partner-Attribution-Id"), "BN_CODE")
        XCTAssertEqual(status, "APPROVED")

        let body = try requestBody(session)
        XCTAssertTrue(body.query.contains("approveApplePayPayment"))
        XCTAssertEqual(body.variables["orderID"] as? String, "ORDER-1")
        XCTAssertEqual(body.variables["clientID"] as? String, "client-id")
        XCTAssertEqual(body.variables["productFlow"] as? String, "CUSTOM_DIGITAL_WALLET")
        XCTAssertTrue(body.variables["shippingContact"] is NSNull)

        let billing = try XCTUnwrap(body.variables["billingContact"] as? [String: Any])
        XCTAssertEqual(billing["countryCode"] as? String, "US")
        let token = try XCTUnwrap(body.variables["token"] as? [String: Any])
        let paymentData = try XCTUnwrap(token["paymentData"] as? [String: Any])
        XCTAssertEqual(paymentData["version"] as? String, "EC_v1")
        XCTAssertEqual(token["transactionIdentifier"] as? String, "txn-1")
    }

    func testConfirm_live_usesLiveGraphQLHost() async throws {
        let (api, session) = try makeAPI(environment: .live, json: approvedJSON)
        _ = try await api.confirm(orderID: "ORDER-1", authorization: sampleAuthorization(countryCode: "US"))
        XCTAssertEqual(
            session.capturedURLRequest?.url?.absoluteString,
            "https://www.paypal.com/graphql?ApproveApplePayPayment"
        )
        XCTAssertNil(session.capturedURLRequest?.value(forHTTPHeaderField: "PayPal-Partner-Attribution-Id"))
    }

    func testFetchConfig_whenGraphQLReturnsAnError_throwsThatMessage() async throws {
        let json = """
        {"errors":[{"message":"APPLEPAY_CONFIG_ERROR"}],"data":null}
        """
        let (api, _) = try makeAPI(environment: .sandbox, json: json)
        do {
            _ = try await api.fetchConfig(buyerCountry: "US")
            XCTFail("Expected config error")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.errorDescription, "APPLEPAY_CONFIG_ERROR")
            XCTAssertEqual(error.code, ApplePayError.Code.confirmationFailed.rawValue)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testConfirm_whenApprovalIsFalse_throws() async throws {
        let (api, _) = try makeAPI(
            environment: .sandbox,
            json: #"{"data":{"approveApplePayPayment":false}}"#
        )
        do {
            _ = try await api.confirm(orderID: "ORDER-1", authorization: sampleAuthorization(countryCode: "US"))
            XCTFail("Expected decline")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, ApplePayError.domain)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    private func makeAPI(
        environment: CoreEnvironment,
        bnCode: String? = nil,
        json: String
    ) throws -> (ApplePayAPI, MockURLSession) {
        let config = CoreConfig(clientID: "client-id", environment: environment, merchantID: "merchant-id", bnCode: bnCode)
        let session = MockURLSession()
        session.cannedJSONData = json
        session.cannedURLResponse = try XCTUnwrap(
            HTTPURLResponse(url: config.environment.graphQLURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        let http = HTTP(urlSession: session, coreConfig: config)
        let api = ApplePayAPI(coreConfig: config, networkingClient: NetworkingClient(http: http))
        return (api, session)
    }

    private func requestBody(_ session: MockURLSession) throws -> (query: String, variables: [String: Any]) {
        let data = try XCTUnwrap(session.capturedURLRequest?.httpBody)
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let query = try XCTUnwrap(json["query"] as? String)
        let variables = try XCTUnwrap(json["variables"] as? [String: Any])
        return (query, variables)
    }

    private func sampleAuthorization(countryCode: String) throws -> ApplePayAuthorization {
        let paymentData = Data(#"{"version":"EC_v1","data":"encrypted","signature":"sig"}"#.utf8)
        let token = try ApplePayPaymentMapper.paymentToken(
            paymentData: paymentData,
            displayName: "Visa 1111",
            network: "Visa",
            type: "debit",
            transactionIdentifier: "txn-1"
        )
        return ApplePayAuthorization(
            token: token,
            billingContact: ApplePayPaymentContact(countryCode: countryCode),
            shippingContact: nil
        )
    }
}
