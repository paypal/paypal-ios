import Foundation
import AuthenticationServices

class WebAuthenticationSession {
    
    var authenticationSession: ASWebAuthenticationSession?
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
    
    func start(url: URL, callbackURLScheme: String, completionHandler: @escaping (URL?, Error?) -> Void) {
        self.authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
        authenticationSession?.prefersEphemeralWebBrowserSession = true
        
        if #available(iOS 13.0, *) {
            authenticationSession?.presentationContextProvider = self.presentationContextProvider
        }
        
        authenticationSession?.start()
    }
}
