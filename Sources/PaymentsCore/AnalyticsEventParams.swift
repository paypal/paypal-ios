import UIKit

// swiftlint:disable identifier_name

struct AnalyticsEventParams: Codable {
    
    // TODO: Convert to camel case, and then use snake-case encoding
    
    var appId: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
    
    var appName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    
//    let c_sdk_ver: String
    
//    let client_id: String
    
    var clientOs: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
    
    var comp = "ppunifiedsdk"
    
    var deviceManufacturer = "Apple"
    
    var eventName: String
    
    var eventSource = "mobile-native"
    
    var iOSPackageManager: String {
        #if COCOAPODS
            return "CocoaPods"
        #elseif SWIFT_PACKAGE
            return "Swift Package Manager"
        #else
            return "Carthage or Other"
        #endif
    }
    
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    var mapv: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
    
//    let merchant_id: String
    
    var mobileDeviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    var platform = "iOS"
    
//    let session_id: String
    
    var t = String(Date().timeIntervalSince1970 * 1000)
    
    var tenantName = "PayPal"
    
    init(eventName: String) {
        self.eventName = eventName
    }
}
