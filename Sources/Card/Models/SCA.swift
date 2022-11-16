import UIKit

/// Strong Customer Authentication launching options
public enum SCA: String {
    
    /// Launch SCA for every transaction
    case scaAlways = "SCA_ALWAYS"
    
    /// Launch SCA challenge only when applicable
    case scaWhenRequired = "SCA_WHEN_REQUIRED"
}
