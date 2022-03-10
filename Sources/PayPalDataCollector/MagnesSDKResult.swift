import Foundation
import PPRiskMagnes

protocol MagnesSDKResult {
    func getPayPalClientMetaDataId() -> String
}

extension MagnesResult: MagnesSDKResult {}
