import Foundation
import PPRiskMagnes

/// Enables you to collect data about a customer's device and correlate it with a session identifier on your server.
public class PayPalDataCollector {

    // MARK: - Properties

    private let magnesSDK: MagnesSDKProtocol
    private let deviceInspector: DeviceInspectorProtocol
    private let magnesEnvironment: MagnesSDK.Environment

    // MARK: - Initializers

    /// Construct an instance to collect device data to send to your server.
    /// - Parameter config: configuration to use when collecting device data
    public convenience init(environment: PayPalDataCollectorEnvironment) {
        self.init(environment: environment, magnesSDK: MagnesSDK.shared(), deviceInspector: DeviceInspector())
    }

    /// internal constructor for testing
    init(environment: PayPalDataCollectorEnvironment, magnesSDK: MagnesSDKProtocol, deviceInspector: DeviceInspectorProtocol) {
        magnesEnvironment = {
            switch environment {
            case .sandbox:
                return .SANDBOX
            case .production:
                return .LIVE
            }
        }()
        self.magnesSDK = magnesSDK
        self.deviceInspector = deviceInspector
    }

    // MARK: - PayPalDataCollector

    /// Collects device data.
    /// - Parameter additionalData: additional key value pairs to correlate with device data
    /// - Returns: A JSON string containing a device data identifier that should be forwarded to your server
    public func collectDeviceData(additionalData: [String: String] = [:]) -> String {
        let deviceIdentifier = deviceInspector.payPalDeviceIdentifier()
        let params = MagnesSetupParams(
            env: magnesEnvironment,
            appGuid: deviceIdentifier,
            isRemoteConfigDisabled: false,
            isBeaconDisabled: false,
            source: .PAYPAL
        )
        try? magnesSDK.setUpWithParams(params)

        let result = try? magnesSDK.collectDeviceData(withPayPalClientMetadataId: "", withAdditionalData: additionalData)
        let clientMetadataId = result?.getPayPalClientMetaDataId() ?? ""

        return "{\"correlation_id\":\"\(clientMetadataId)\"}"
    }
}
