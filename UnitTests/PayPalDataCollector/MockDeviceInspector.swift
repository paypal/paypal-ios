
import Foundation
@testable import PayPalDataCollector

class MockDeviceInspector: DeviceInspectorProtocol {

    var paypalDeviceIdentifierValue: String = ""

    func paypalDeviceIdentifier() -> String {
        return paypalDeviceIdentifierValue
    }

    func stubPayPalDeviceIdentifierWithValue(_ value: String) {
        paypalDeviceIdentifierValue = value
    }
}
