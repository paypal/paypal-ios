import Foundation
import CardPayments
import CorePayments
import SwiftUI

@MainActor
@Observable
class CardVaultViewModelV2 {
    
    var isLoadingSetupToken = false
    
    func createSetupToken(with request: DemoCreateSetupTokenRequest) {
        print(request.customerID)
    }
}
