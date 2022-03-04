
import Foundation
@testable import PayPalDataCollector

class MockMagnesSDKResult: MagnesSDKResult {
    
    func getPayPalClientMetaDataId() -> String {
        return ""
    }
}
