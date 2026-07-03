import Foundation

#if DEBUG
struct CustomEnvironmentConfig: Codable, Equatable {
    var clientID: String
    var restBaseURL: String
    var graphQLBaseURL: String
}
#endif

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let ClientIDKey = "clientID"
    private static let MerchantIntegrationDefaultKey = "merchantIntegration"
    #if DEBUG
    private static let CustomEnvironmentKey = "customEnvironment"
    #endif

    static var environment: Environment {
        get {
            let stored = UserDefaults.standard.string(forKey: EnvironmentDefaultsKey)
                .flatMap { Environment(rawValue: $0) } ?? .sandbox
            #if DEBUG
            if stored == .custom, customEnvironment == nil {
                return .sandbox
            }
            #endif
            return stored
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: EnvironmentDefaultsKey)
        }
    }

    #if DEBUG
    static var customEnvironment: CustomEnvironmentConfig? {
        get {
            guard let data = UserDefaults.standard.data(forKey: CustomEnvironmentKey) else {
                return nil
            }
            return try? JSONDecoder().decode(CustomEnvironmentConfig.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: CustomEnvironmentKey)
            } else {
                UserDefaults.standard.removeObject(forKey: CustomEnvironmentKey)
            }
        }
    }
    #endif

    static var merchantIntegration: MerchantIntegration {
        get {
            if let savedDisplayName = UserDefaults.standard.string(forKey: MerchantIntegrationDefaultKey),
            let matchingCase = MerchantIntegration.allCases.first(where: { $0.displayName == savedDisplayName }) {
                return matchingCase
            }
            return MerchantIntegration.default
        }
        set {
            UserDefaults.standard.set(newValue.displayName, forKey: MerchantIntegrationDefaultKey)
        }
    }
}
