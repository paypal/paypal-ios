import Foundation
import PPRiskMagnes
@testable import FraudProtection

struct CollectDeviceDataArgs: Hashable {

    let payPalClientMetadataId: String
    let additionalData: [String: String]
}

class MockMagnesSDK: MagnesSDKProtocol {

    var collectDeviceDataStubs: [CollectDeviceDataArgs: MockMagnesSDKResult] = [:]

    var capturedSetupParams: MagnesSetupParams?

    func setUpWithParams(_ magnesParams: MagnesSetupParams) throws {
        capturedSetupParams = magnesParams
    }

    func collectDeviceData(
        withPayPalClientMetadataId cmid: String,
        withAdditionalData additionalData: [String: String]
    ) throws -> MagnesSDKResult {
        let args = CollectDeviceDataArgs(payPalClientMetadataId: cmid, additionalData: additionalData)
        return collectDeviceDataStubs[args] ?? MockMagnesSDKResult()
    }

    func stubCollectDeviceData(forArgs args: CollectDeviceDataArgs, withValue result: MockMagnesSDKResult) {
        collectDeviceDataStubs[args] = result
    }
}
