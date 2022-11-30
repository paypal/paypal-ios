import UIKit

struct AnalyticsEventData: Encodable {
    
    enum TopLevelKeys: String, CodingKey {
        case events
    }
    
    enum EventKeys: String, CodingKey {
        case eventParameters = "event_params"
    }
    
    enum EventParameterKeys: String, CodingKey, CaseIterable {
        case appID = "app_id"
        case appName = "app_name"
        case clientSDKVersion = "c_sdk_ver"
        case clientOS = "client_os"
        case component = "comp"
        case deviceManufacturer = "device_manufacturer"
        case eventName = "event_name"
        case eventSource = "event_source"
        case packageManager = "ios_package_manager"
        case isSimulator = "is_simulator"
        case merchantAppVersion = "mapv"
        case deviceModel = "mobile_device_model"
        case platform = "platform"
        case sessionID = "session_id"
        case timestamp = "t"
        case tenantName = "tenant_name"
    }
    
    let appID: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "N/A"
    
    let appName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "N/A"

    let clientSDKVersion = PayPalCoreConstants.payPalSDKVersion

    let clientOS: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion

    let component = "ppunifiedsdk"

    let deviceManufacturer = "Apple"

    let eventName: String

    let eventSource = "mobile-native"

    let packageManager: String = {
        #if COCOAPODS
            "CocoaPods"
        #elseif SWIFT_PACKAGE
            "Swift Package Manager"
        #else
            "Carthage or Other"
        #endif
    }()

    let isSimulator: Bool = {
        #if targetEnvironment(simulator)
            true
        #else
            false
        #endif
    }()
    
    let merchantAppVersion: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "N/A"

    let deviceModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()

    let platform = "iOS"

    let sessionID: String

    let timestamp = String(Date().timeIntervalSince1970 * 1000)

    let tenantName = "PayPal"
    
    init(eventName: String, sessionID: String) {
        self.eventName = eventName
        self.sessionID = sessionID
    }
    
    func encode(to encoder: Encoder) throws {
        var topLevel = encoder.container(keyedBy: TopLevelKeys.self)
        var events = topLevel.nestedContainer(keyedBy: EventKeys.self, forKey: .events)
        var eventParameters = events.nestedContainer(keyedBy: EventParameterKeys.self, forKey: .eventParameters)
        
        try eventParameters.encode(appID, forKey: .appID)
        try eventParameters.encode(appName, forKey: .appName)
        try eventParameters.encode(clientSDKVersion, forKey: .clientSDKVersion)
        try eventParameters.encode(clientOS, forKey: .clientOS)
        try eventParameters.encode(component, forKey: .component)
        try eventParameters.encode(deviceManufacturer, forKey: .deviceManufacturer)
        try eventParameters.encode(eventName, forKey: .eventName)
        try eventParameters.encode(eventSource, forKey: .eventSource)
        try eventParameters.encode(packageManager, forKey: .packageManager)
        try eventParameters.encode(isSimulator, forKey: .isSimulator)
        try eventParameters.encode(merchantAppVersion, forKey: .merchantAppVersion)
        try eventParameters.encode(deviceModel, forKey: .deviceModel)
        try eventParameters.encode(platform, forKey: .platform)
        try eventParameters.encode(sessionID, forKey: .sessionID)
        try eventParameters.encode(timestamp, forKey: .timestamp)
        try eventParameters.encode(tenantName, forKey: .tenantName)
    }
}
