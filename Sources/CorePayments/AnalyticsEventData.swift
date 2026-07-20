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
        case appSwitchEligible = "app_switch_eligible"
        case appSwitchURL = "app_switch_url"
        case bnCode = "bn_code"
        case buttonType = "button_type"
        case cancelAppURL = "cancel_app_url"
        case clientID = "partner_client_id"
        case clientOS = "client_os"
        case clientSDKVersion = "c_sdk_ver"
        case component = "comp"
        case correlationID = "correlation_id"
        case deviceManufacturer = "device_manufacturer"
        case deviceModel = "mobile_device_model"
        case environment = "merchant_sdk_env"
        case errorDescription = "error_description"
        case eventName = "event_name"
        case eventSource = "event_source"
        case fallbackSchemeURL = "fallback_scheme_url"
        case fallbackUrl = "fallback_url"
        case ineligibleReason = "ineligible_reason"
        case isCachedSession = "is_cached_session"
        case isSimulator = "is_simulator"
        case isVaultRequest = "is_vault_request"
        case merchantAppVersion = "mapv"
        case merchantID = "merchant_id"
        case orderID = "order_id"
        case packageManager = "ios_package_manager"
        case paypalNativeAppInstalled = "paypal_native_app_installed"
        case platform = "platform"
        case returnAppURL = "return_app_url"
        case setupToken = "vault_setup_token"
        case shopperSessionExpiration = "shopper_session_expiration"
        case shopperSessionId = "shopper_session_id"
        case startTime = "start_time"
        case tenantName = "tenant_name"
        case timestamp = "t"
        case userAction = "user_action"
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

    let merchantID: String

    let bnCode: String?

    let appSwitchURL: URL?

    let appSwitchEligible: Bool?

    let ineligibleReason: String?

    let fallbackUrl: String?

    let fallbackSchemeURL: URL?

    let returnAppURL: URL?

    let cancelAppURL: URL?

    let userAction: String?

    let paypalNativeAppInstalled: Bool?

    let errorDescription: String?

    let isCachedSession: Bool?

    let isVaultRequest: Bool?

    let shopperSessionId: String?

    let shopperSessionExpiration: String?

    init(
        environment: String,
        eventName: String,
        clientID: String,
        merchantID: String,
        bnCode: String?,
        orderID: String?,
        correlationID: String?,
        setupToken: String?,
        buttonType: String? = nil,
        errorDescription: String? = nil,
        checkoutAnalyticsData: PayPalCheckoutAnalyticsData? = nil
    ) {
        self.environment = environment
        self.eventName = eventName
        self.clientID = clientID
        self.merchantID = merchantID
        self.bnCode = bnCode
        self.orderID = orderID
        self.correlationID = correlationID
        self.setupToken = setupToken
        self.buttonType = buttonType
        self.appSwitchURL = checkoutAnalyticsData?.appSwitchURL
        self.appSwitchEligible = checkoutAnalyticsData?.appSwitchEligible
        self.ineligibleReason = checkoutAnalyticsData?.ineligibleReason
        self.fallbackUrl = checkoutAnalyticsData?.fallbackUrl
        self.fallbackSchemeURL = checkoutAnalyticsData?.fallbackSchemeURL
        self.returnAppURL = checkoutAnalyticsData?.returnAppURL
        self.cancelAppURL = checkoutAnalyticsData?.cancelAppURL
        self.userAction = checkoutAnalyticsData?.userAction
        self.paypalNativeAppInstalled = checkoutAnalyticsData?.paypalNativeAppInstalled
        self.errorDescription = errorDescription
        self.isCachedSession = checkoutAnalyticsData?.isCachedSession
        self.isVaultRequest = checkoutAnalyticsData?.isVaultRequest
        self.shopperSessionId = checkoutAnalyticsData?.shopperSessionID
        self.shopperSessionExpiration = checkoutAnalyticsData?.shopperSessionExpiration
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
        try eventParameters.encode(buttonType, forKey: .buttonType)
        try eventParameters.encode(merchantID, forKey: .merchantID)
        try eventParameters.encode(bnCode, forKey: .bnCode)
        try eventParameters.encode(appSwitchURL, forKey: .appSwitchURL)
        try eventParameters.encode(appSwitchEligible, forKey: .appSwitchEligible)
        try eventParameters.encode(ineligibleReason, forKey: .ineligibleReason)
        try eventParameters.encode(fallbackUrl, forKey: .fallbackUrl)
        try eventParameters.encode(fallbackSchemeURL, forKey: .fallbackSchemeURL)
        try eventParameters.encode(returnAppURL, forKey: .returnAppURL)
        try eventParameters.encode(cancelAppURL, forKey: .cancelAppURL)
        try eventParameters.encode(userAction, forKey: .userAction)
        try eventParameters.encode(paypalNativeAppInstalled, forKey: .paypalNativeAppInstalled)
        try eventParameters.encode(errorDescription, forKey: .errorDescription)
        try eventParameters.encode(isCachedSession, forKey: .isCachedSession)
        try eventParameters.encode(isVaultRequest, forKey: .isVaultRequest)
        try eventParameters.encode(shopperSessionId, forKey: .shopperSessionId)
        try eventParameters.encode(shopperSessionExpiration, forKey: .shopperSessionExpiration)
    }
}
