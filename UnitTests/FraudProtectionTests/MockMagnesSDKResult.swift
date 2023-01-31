import Foundation
@testable import FraudProtection

class MockMagnesSDKResult: MagnesSDKResult {

    var payPalClientMetaDataId: String

    init(payPalClientMetaDataId: String = "") {
        self.payPalClientMetaDataId = payPalClientMetaDataId
    }

    func getPayPalClientMetaDataId() -> String {
        return payPalClientMetaDataId
    }
}
