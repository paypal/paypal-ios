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
        case .custom:
            // TODO: determine if this is correct, or if Magnes also needs to be custom
            return .SANDBOX
        }
    }
}
