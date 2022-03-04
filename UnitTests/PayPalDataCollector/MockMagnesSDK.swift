
import Foundation
import PPRiskMagnes
@testable import PayPalDataCollector

class MockMagnesSDK: MagnesSDKProtocol {

    var capturedSetupParams: MagnesSetupParams?

    func setUpWithParams(_ magnesParams: MagnesSetupParams) throws {
        capturedSetupParams = magnesParams
    }

    func collectDeviceData(
        withPayPalClientMetadataId cmid: String,
        withAdditionalData additionalData: [String: String]
    ) throws -> MagnesSDKResult {
        return MockMagnesSDKResult()
    }
}
