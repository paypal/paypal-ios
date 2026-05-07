import Foundation

@Observable
class DemoCreateOrderRequest {
    
    var intent: Intent = .authorize
    var shouldVault = false
    var vaultCustomerID = ""
}
