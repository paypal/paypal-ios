import Foundation
import PPRiskMagnes

struct MagnesSetupParams {

    let env: MagnesSDK.Environment
    let appGuid: String
    let isRemoteConfigDisabled: Bool
    let isBeaconDisabled: Bool
    let source: MagnesSDK.MagnesSource
}
