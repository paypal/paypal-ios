
import CorePayments
import PPRiskMagnes

extension CoreConfig {
    
    var magnesEnvironment: MagnesSDK.Environment {
        switch (self.environment) {
        case .sandbox:
            return .SANDBOX
        case .live:
            return .LIVE
        }
    }
}
