import CorePayments
import PPRiskMagnes

extension CoreConfig {
    
    var magnesEnvironment: MagnesSDK.Environment {
        switch environment {
        case .sandbox:
            return .SANDBOX
        case .live:
            return .LIVE
        }
    }
}
