import XCTest
@testable import FraudProtection

class DeviceInspector_Tests: XCTestCase {

    func testPayPalDeviceIdentifier_shouldReturnANewIdentifierIfOneDoesNotExist() {
        clearPayPalDeviceIdentifier()

        let sut = DeviceInspector()
        let newIdentifier = UUID()
        let result = sut.payPalDeviceIdentifier(newIdentifier: newIdentifier)

        XCTAssertEqual(newIdentifier.uuidString, result)
    }

    func testPayPalDeviceIdentifier_shouldReturnAnExistingIdentifierIfOneDoesExist() throws {
        // Ref: https://developer.apple.com/forums/thread/60617
        #if targetEnvironment(simulator)
            throw XCTSkip("Keychain Access does not work in simulator")
        #else
            let sut = DeviceInspector()
            let newIdentifier = UUID()
            let result = sut.payPalDeviceIdentifier(newIdentifier: newIdentifier)

            XCTAssertNotEqual(newIdentifier.uuidString, result)
        #endif
    }

    func clearPayPalDeviceIdentifier() {
        let accountName = "com.paypal.ios-sdk.PayPalDataCollector.DeviceGUID"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Service",
            kSecAttrAccount as String: accountName
        ]
        _ = SecItemDelete(query as CFDictionary)
    }
}
