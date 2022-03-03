import Foundation
import PPRiskMagnes

protocol MagnesSDKProtocol {
    func setUpWithParams(_ magnesParams: MagnesSetupParams) throws
    func collectAndSubmit(
        withPayPalClientMetadataId cmid: String,
        withAdditionalData additionalData: [String: String]
    ) throws -> MagnesResult
}

extension MagnesSDK: MagnesSDKProtocol {

    func setUpWithParams(_ params: MagnesSetupParams) throws {
        // workaround to avoid lint errors
        try setUp(
            setEnviroment: params.env,
            setOptionalAppGuid: params.appGuid,
            setOptionalAPNToken: params.apnToken,
            disableRemoteConfiguration: params.isRemoteConfigDisabled,
            disableBeacon: params.isBeaconDisabled,
            magnesSource: params.source
        )
    }
}
