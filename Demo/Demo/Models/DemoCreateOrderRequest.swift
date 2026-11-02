import Foundation

@Observable
class DemoCreateOrderRequest {
    
    var amount = "10.00"
    var intent: Intent = .authorize
    var shouldVault = false
    var vaultCustomerID = ""
}
