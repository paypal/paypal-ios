import Foundation
import PPRiskMagnes
import PaymentsCore

public class PayPalDataCollector {

    // MARK: - Properties
    private let config: CoreConfig
    private let magnesSDK: MagnesSDKProtocol
    private let deviceInspector: DeviceInspectorProtocol

    // MARK: - Initializers
    public convenience init(config: CoreConfig) {
        self.init(config: config, magnesSDK: MagnesSDK.shared(), deviceInspector: DeviceInspector())
    }

    init(config: CoreConfig, magnesSDK: MagnesSDKProtocol, deviceInspector: DeviceInspectorProtocol) {
        self.config = config
        self.magnesSDK = magnesSDK
        self.deviceInspector = deviceInspector
    }

    // MARK: - Computed Properties
    private var magnesEnvironment: MagnesSDK.Environment {
        switch config.environment {
        case .sandbox:
            return .SANDBOX
        case .production:
            return .LIVE
        }
    }

    // MARK: - PayPalDataCollector
    public func collectDeviceData(additionalData: [String: String] = [:]) -> String {
        let deviceIdentifier = deviceInspector.payPalDeviceIdentifier()
        let params = MagnesSetupParams(
            env: magnesEnvironment,
            appGuid: deviceIdentifier,
            apnToken: "",
            isRemoteConfigDisabled: false,
            isBeaconDisabled: false,
            source: .PAYPAL
        )
        try? magnesSDK.setUpWithParams(params)

        let result = try? magnesSDK.collectDeviceData(withPayPalClientMetadataId: "", withAdditionalData: additionalData)
        let clientMetadataId = result?.getPayPalClientMetaDataId() ?? ""

        return """
            {"correlation_id":"\(clientMetadataId)"}
        """.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
