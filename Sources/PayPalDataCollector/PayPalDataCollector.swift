import Foundation
import PPRiskMagnes

public class PayPalDataCollector {
    
    private let instance: MagnesSDKProtocol
    
    init(instance: MagnesSDKProtocol = MagnesSDK.shared()) {
        self.instance = instance
    }
}
