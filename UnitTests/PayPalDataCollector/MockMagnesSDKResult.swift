import Foundation
@testable import PayPalDataCollector

class MockMagnesSDKResult: MagnesSDKResult {

    var paypalClientMetaDataId: String

    init(paypalClientMetaDataId: String = "") {
        self.paypalClientMetaDataId = paypalClientMetaDataId
    }

    func getPayPalClientMetaDataId() -> String {
        return paypalClientMetaDataId
    }
}
