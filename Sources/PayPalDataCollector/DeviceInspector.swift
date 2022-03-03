import Foundation

class DeviceInspector: DeviceInspectorProtocol {

    func paypalDeviceIdentifier() -> String {
        let accountName = "com.paypal.ios-sdk.PayPalDataCollector.PayPal_MPL_DeviceGUID"
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Service",
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess,
            let existingItem = item as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data,
            let identifier = String(data: data, encoding: String.Encoding.utf8) {
            return identifier
        }

        let newIdentifier = UUID().uuidString
        query[kSecValueData as String] = newIdentifier
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
        return newIdentifier
    }
}
