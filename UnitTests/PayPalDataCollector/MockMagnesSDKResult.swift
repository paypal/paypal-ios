import Foundation
@testable import PayPalDataCollector

class MockMagnesSDKResult: MagnesSDKResult {

    var payPalClientMetaDataId: String

    init(payPalClientMetaDataId: String = "") {
        self.payPalClientMetaDataId = payPalClientMetaDataId
    }

    func getPayPalClientMetaDataId() -> String {
        return payPalClientMetaDataId
    }
}
