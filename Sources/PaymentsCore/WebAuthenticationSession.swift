import Foundation
import AuthenticationServices

class WebAuthenticationSession {
    
    var authenticationSession: ASWebAuthenticationSession?
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
    
    func start(url: URL, callbackURLScheme: String, completionHandler: @escaping (URL?, Error?) -> Void) {
        self.authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
        
        authenticationSession?.start()
    }
    
    @available(iOS 13.0, *)
    func start(url: URL, callbackURLScheme: String, context: ASWebAuthenticationPresentationContextProviding, completionHandler: @escaping (URL?, Error?) -> Void) {
        self.authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
        
        authenticationSession?.presentationContextProvider = context

        authenticationSession?.start()
    }
    
}
