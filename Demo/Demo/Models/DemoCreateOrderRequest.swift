import Foundation

class DemoCreateOrderRequest: ObservableObject {
    
    @Published var intent: Intent = .authorize
    @Published var shouldVault = false
    @Published var vaultCustomerID = ""
}
