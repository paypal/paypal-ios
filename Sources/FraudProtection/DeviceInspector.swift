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
        if saveDeviceIDtoKeychain(newDeviceID) {
            return newDeviceID
        }
        return getDeviceIDFromKeychain() ?? newDeviceID
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
        return Self.deviceIdentifier(fromKeychainResult: status, item: item)
    }

    /// `SecItemCopyMatching` with `kSecReturnData` returns `Data`, not a dictionary.
    /// Reading it as a dictionary dropped the saved id and made Magnes mint a new signing key on every call.
    static func deviceIdentifier(fromKeychainResult status: OSStatus, item: CFTypeRef?) -> String? {
        guard status == errSecSuccess, let item else {
            return nil
        }

        let data: Data?
        if let value = item as? Data {
            data = value
        } else if let dictionary = item as? [String: Any] {
            data = dictionary[kSecValueData as String] as? Data
        } else {
            data = nil
        }

        guard let data, let identifier = String(data: data, encoding: .utf8), !identifier.isEmpty else {
            return nil
        }
        return identifier
    }

    @discardableResult
    private func saveDeviceIDtoKeychain(_ deviceID: String) -> Bool {
        guard let deviceIDData = deviceID.data(using: .utf8) else {
            return false
        }
        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountName,
            kSecAttrService as String: "Service",
            kSecValueData as String: deviceIDData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        return status == errSecSuccess
    }
}
