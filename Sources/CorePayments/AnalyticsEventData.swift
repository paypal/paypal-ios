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
        case appSwitchURL = "app_switch_url"
        case buttonType = "button_type"
        case clientID = "partner_client_id"
        case clientOS = "client_os"
        case clientSDKVersion = "c_sdk_ver"
        case component = "comp"
        case correlationID = "correlation_id"
        case deviceManufacturer = "device_manufacturer"
        case deviceModel = "mobile_device_model"
        case endpoint = "endpoint"
        case environment = "merchant_sdk_env"
        case errorDescription = "error_description"
        case eventName = "event_name"
        case eventSource = "event_source"
        case flow = "flow"
        case isCachedSession = "is_cached_session"
        case isSimulator = "is_simulator"
        case isVaultRequest = "is_vault_request"
        case merchantAppVersion = "mapv"
        case orderID = "order_id"
        case packageManager = "ios_package_manager"
        case platform = "platform"
        case presentationType = "presentation_type"
        case setupToken = "vault_setup_token"
        case shopperSessionId = "shopper_session_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case tenantName = "tenant_name"
        case timestamp = "t"
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

    let orderID: String?

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

    let setupToken: String?

    let timestamp = String(Date().timeIntervalSince1970 * 1000)

    let tenantName = "PayPal"

    let buttonType: String?

    let appSwitchURL: URL?

    let errorDescription: String?

    let isCachedSession: Bool?

    let isVaultRequest: Bool?

    let shopperSessionId: String?

    /// Epoch milliseconds. Used for SSID session timing (Int) and latency events (Int64).
    let startTime: Int64?

    let endTime: Int64?

    let endpoint: String?

    let presentationType: String?

    let flow: String?

    init(
        environment: String,
        eventName: String,
        clientID: String,
        orderID: String?,
        correlationID: String?,
        setupToken: String?,
        buttonType: String? = nil,
        appSwitchURL: URL? = nil,
        errorDescription: String? = nil,
        isCachedSession: Bool? = nil,
        isVaultRequest: Bool? = nil,
        shopperSessionId: String? = nil,
        startTime: Int64? = nil,
        endTime: Int64? = nil,
        endpoint: String? = nil,
        presentationType: String? = nil,
        flow: String? = nil
    ) {
        self.environment = environment
        self.eventName = eventName
        self.clientID = clientID
        self.orderID = orderID
        self.correlationID = correlationID
        self.setupToken = setupToken
        self.buttonType = buttonType
        self.appSwitchURL = appSwitchURL
        self.errorDescription = errorDescription
        self.isCachedSession = isCachedSession
        self.isVaultRequest = isVaultRequest
        self.shopperSessionId = shopperSessionId
        self.startTime = startTime
        self.endTime = endTime
        self.endpoint = endpoint
        self.presentationType = presentationType
        self.flow = flow
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
        try eventParameters.encode(setupToken, forKey: .setupToken)
        try eventParameters.encodeIfPresent(buttonType, forKey: .buttonType)
        try eventParameters.encodeIfPresent(appSwitchURL, forKey: .appSwitchURL)
        try eventParameters.encodeIfPresent(errorDescription, forKey: .errorDescription)
        try eventParameters.encodeIfPresent(isCachedSession, forKey: .isCachedSession)
        try eventParameters.encodeIfPresent(isVaultRequest, forKey: .isVaultRequest)
        try eventParameters.encodeIfPresent(shopperSessionId, forKey: .shopperSessionId)
        try eventParameters.encodeIfPresent(startTime, forKey: .startTime)
        try eventParameters.encodeIfPresent(endTime, forKey: .endTime)
        try eventParameters.encodeIfPresent(endpoint, forKey: .endpoint)
        try eventParameters.encodeIfPresent(presentationType, forKey: .presentationType)
        try eventParameters.encodeIfPresent(flow, forKey: .flow)
    }
}
