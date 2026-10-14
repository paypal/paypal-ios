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

    func testDeviceIdentifier_readsDataReturnedBySecItemCopyMatching() {
        let stored = Data("stable-device-id".utf8)
        let identifier = DeviceInspector.deviceIdentifier(fromKeychainResult: errSecSuccess, item: stored as CFTypeRef)

        XCTAssertEqual("stable-device-id", identifier)
    }

    func testDeviceIdentifier_readsLegacyDictionaryResult() {
        let stored = Data("legacy-device-id".utf8)
        let dictionary: [String: Any] = [kSecValueData as String: stored]
        let identifier = DeviceInspector.deviceIdentifier(fromKeychainResult: errSecSuccess, item: dictionary as CFTypeRef)

        XCTAssertEqual("legacy-device-id", identifier)
    }

    func testDeviceIdentifier_returnsNilWhenKeychainLookupFails() {
        let identifier = DeviceInspector.deviceIdentifier(fromKeychainResult: errSecItemNotFound, item: nil)

        XCTAssertNil(identifier)
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
