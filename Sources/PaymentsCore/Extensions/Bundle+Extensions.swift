import Foundation

extension Bundle {

  var shortVersion: String? {
    infoDictionary?["CFBundleShortVersionString"] as? String
  }

  var version: String? {
    infoDictionary?[kCFBundleVersionKey as String] as? String
  }
}
