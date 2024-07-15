import CorePayments
import Foundation

struct VenmoState {

    var isVenmoEligible: Bool?
    
    var isVenmoEligibleResponse: LoadingState<Bool> = .idle {
        didSet {
            if case .loaded(let value) = isVenmoEligibleResponse {
                isVenmoEligible = value
            }
        }
    }
}
