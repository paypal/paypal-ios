import CorePayments
import Foundation

class VenmoPaymentsViewModel: ObservableObject {
    
    let configManager = CoreConfigManager(domain: "Venmo Payments")
    
    @Published var state = VenmoState()
    
    func getEligibility() async throws {
        DispatchQueue.main.async {
            self.state.isVenmoEligibleResponse = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let eligibilityRequest = EligibilityRequest(currencyCode: "USD", intent: .CAPTURE)
            let eligibilityClient = EligibilityClient(config: config)
            let eligibilityResult = try? await eligibilityClient.check(eligibilityRequest)
            let isVenmoEligible = eligibilityResult?.isVenmoEligible ?? false
            
            DispatchQueue.main.async {
                self.state.isVenmoEligibleResponse = .loaded(isVenmoEligible)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.isVenmoEligibleResponse = .error(message: error.localizedDescription)
            }
            print("failed in updating setup token. \(error.localizedDescription)")
        }
    }
}
