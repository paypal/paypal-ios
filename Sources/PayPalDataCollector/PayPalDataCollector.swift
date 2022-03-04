import Foundation
import PPRiskMagnes

public class PayPalDataCollector {

    private let magnesSDK: MagnesSDKProtocol
    private let deviceInspector: DeviceInspectorProtocol

    public convenience init() {
        self.init(magnesSDK: MagnesSDK.shared(), deviceInspector: DeviceInspector())
    }

    init(magnesSDK: MagnesSDKProtocol, deviceInspector: DeviceInspectorProtocol) {
        self.magnesSDK = magnesSDK
        self.deviceInspector = deviceInspector
    }

    public func collectDeviceData(additionalData: [String: String] = [:]) -> String {
        let deviceIdentifier = deviceInspector.paypalDeviceIdentifier()
        let params = MagnesSetupParams(
            env: .LIVE,
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
