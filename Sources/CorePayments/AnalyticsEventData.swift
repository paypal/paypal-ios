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
        case clientID = "partner_client_id"
        case clientSDKVersion = "c_sdk_ver"
        case clientOS = "client_os"
        case component = "comp"
        case correlationID = "correlation_id"
        case deviceManufacturer = "device_manufacturer"
        case environment = "merchant_sdk_env"
        case eventName = "event_name"
        case eventSource = "event_source"
        case orderID = "order_id"
        case packageManager = "ios_package_manager"
        case isSimulator = "is_simulator"
        case merchantAppVersion = "mapv"
        case deviceModel = "mobile_device_model"
        case platform = "platform"
        case timestamp = "t"
        case tenantName = "tenant_name"
    }
    
    let appID: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "N/A"
    
    let appName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "N/A"
    
    let clientID: String

    let clientSDKVersion = PayPalCoreConstants.payPalSDKVersion

    let clientOS: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion

    let component = "ppcpclientsdk"

    let correlationID: String?

    let deviceManufacturer = "Apple"

    let eventName: String

    let eventSource = "mobile-native"
    
    let environment: String
    
    let orderID: String

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

    let timestamp = String(Date().timeIntervalSince1970 * 1000)

    let tenantName = "PayPal"
    
    init(environment: String, eventName: String, clientID: String, orderID: String, correlationID: String?) {
        self.environment = environment
        self.eventName = eventName
        self.clientID = clientID
        self.orderID = orderID
        self.correlationID = correlationID
    }
    
    func encode(to encoder: Encoder) throws {
        var topLevel = encoder.container(keyedBy: TopLevelKeys.self)
        var events = topLevel.nestedContainer(keyedBy: EventKeys.self, forKey: .events)
        var eventParameters = events.nestedContainer(keyedBy: EventParameterKeys.self, forKey: .eventParameters)
        
        try eventParameters.encode(appID, forKey: .appID)
        try eventParameters.encode(appName, forKey: .appName)
        try eventParameters.encode(clientID, forKey: .clientID)
        try eventParameters.encode(clientSDKVersion, forKey: .clientSDKVersion)
        try eventParameters.encode(clientOS, forKey: .clientOS)
        try eventParameters.encode(component, forKey: .component)
        try eventParameters.encode(correlationID, forKey: .correlationID)
        try eventParameters.encode(deviceManufacturer, forKey: .deviceManufacturer)
        try eventParameters.encode(environment, forKey: .environment)
        try eventParameters.encode(eventName, forKey: .eventName)
        try eventParameters.encode(eventSource, forKey: .eventSource)
        try eventParameters.encode(packageManager, forKey: .packageManager)
        try eventParameters.encode(isSimulator, forKey: .isSimulator)
        try eventParameters.encode(merchantAppVersion, forKey: .merchantAppVersion)
        try eventParameters.encode(deviceModel, forKey: .deviceModel)
        try eventParameters.encode(platform, forKey: .platform)
        try eventParameters.encode(orderID, forKey: .orderID)
        try eventParameters.encode(timestamp, forKey: .timestamp)
        try eventParameters.encode(tenantName, forKey: .tenantName)
    }
}
