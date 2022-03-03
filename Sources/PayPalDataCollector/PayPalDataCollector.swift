import Foundation
import PPRiskMagnes

public class PayPalDataCollector {

    private let deviceIdentifier: String
    private let magnesSDK: MagnesSDKProtocol

    init(magnesSDK: MagnesSDKProtocol = MagnesSDK.shared(), deviceIdentifier: String) {
        self.magnesSDK = magnesSDK
        self.deviceIdentifier = deviceIdentifier
    }

    public func collectDeviceData(additionalData: [String: String] = [:]) -> String {
        let params = MagnesSetupParams(
            env: .LIVE,
            appGuid: deviceIdentifier,
            apnToken: "",
            isRemoteConfigDisabled: false,
            isBeaconDisabled: false,
            source: .BRAINTREE
        )
        try? magnesSDK.setUpWithParams(params)
        
        let result = try? magnesSDK.collectAndSubmit(withPayPalClientMetadataId: "", withAdditionalData: additionalData)
        let clientMetadataId = result?.getPayPalClientMetaDataId() ?? ""
        
        return """
            { "correlation_id": "\(clientMetadataId)" }
        """.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
