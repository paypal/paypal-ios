import Foundation

/// Default response type for network requests that do not rely on any response body data.
/// For example, some requests just check for a particular status code to confirm success (ie `204 OK`)
public struct EmptyResponse: Codable {
    // Intentionally empty
}
