import Foundation

class DeviceInspectorHelper {

    func setPayPalDeviceIdentifier() {
        let accountName = "com.paypal.ios-sdk.PayPalDataCollector.DeviceGUID"
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Service",
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true
        ]
    }
    
    func clearPayPalDeviceIdentifier() {
        let accountName = "com.paypal.ios-sdk.PayPalDataCollector.DeviceGUID"
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Service",
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true
        ]
        SecItemDelete(query as CFDictionary)
    }
}
