import PPRiskMagnes
#if canImport(CorePayments)
import CorePayments
#endif

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
