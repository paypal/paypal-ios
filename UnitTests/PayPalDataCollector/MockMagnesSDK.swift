
import Foundation
import PPRiskMagnes
@testable import PayPalDataCollector

class MockMagnesSDK: MagnesSDKProtocol {

    func setUpWithParams(_ magnesParams: MagnesSetupParams) throws {
    }

    func didSetUpWithParams(_ expectedParams: MagnesSetupParams) -> Bool {
        return false
    }
    
    func collectDeviceData(
        withPayPalClientMetadataId cmid: String,
        withAdditionalData additionalData: [String: String]
    ) throws -> MagnesSDKResult {
        return MockMagnesSDKResult()
    }
}
