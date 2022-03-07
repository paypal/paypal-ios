import Foundation

class DeviceInspector: DeviceInspectorProtocol {

    private let accountName = "com.paypal.ios-sdk.PayPalDataCollector.DeviceGUID"

    func payPalDeviceIdentifier() -> String {
        payPalDeviceIdentifier(newIdentifier: UUID())
    }

    func payPalDeviceIdentifier(newIdentifier: UUID) -> String {
        if let deviceID = getDeviceIDFromKeychain() {
            return deviceID
        }

        let newDeviceID = newIdentifier.uuidString
        saveDeviceIDtoKeychain(newDeviceID)
        return newDeviceID
    }

    private func getDeviceIDFromKeychain() -> String? {
        let searchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountName,
            kSecAttrService as String: "Service",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        if status == errSecSuccess,
            let existingItem = item as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data,
            let identifier = String(data: data, encoding: .utf8) {
            return identifier
        }
        return nil
    }

    private func saveDeviceIDtoKeychain(_ deviceID: String) {
        if let deviceIDData = deviceID.data(using: .utf8) {
            let saveQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: accountName,
                kSecAttrService as String: "Service",
                kSecValueData as String: deviceIDData,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            _ = SecItemAdd(saveQuery as CFDictionary, nil)
        }
    }
}
