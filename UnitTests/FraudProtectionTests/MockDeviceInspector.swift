import Foundation
@testable import FraudProtection

class MockDeviceInspector: DeviceInspectorProtocol {

    var payPalDeviceIdentifierValue: String = ""

    func payPalDeviceIdentifier() -> String {
        return payPalDeviceIdentifierValue
    }

    func stubPayPalDeviceIdentifierWithValue(_ value: String) {
        payPalDeviceIdentifierValue = value
    }
}
