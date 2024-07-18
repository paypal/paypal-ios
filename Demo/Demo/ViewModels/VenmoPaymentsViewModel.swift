import CorePayments
import Foundation

class VenmoPaymentsViewModel: ObservableObject {
    
    let configManager = CoreConfigManager(domain: "Venmo Payments")
    
    @Published var state: CurrentState = .idle
    
    private var eligibilityResult: EligibilityResult?
    
    var isVenmoEligible: Bool {
        eligibilityResult?.isVenmoEligible ?? false
    }
    
    func getEligibility(_ intent: EligibilityIntent) async throws {
        DispatchQueue.main.async {
            self.state = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let eligibilityRequest = EligibilityRequest(currencyCode: "USD", intent: intent)
            let eligibilityClient = EligibilityClient(config: config)
            eligibilityResult = try? await eligibilityClient.check(eligibilityRequest)

            DispatchQueue.main.async {
                self.state = .success
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(message: error.localizedDescription)
            }
            print("failed in updating setup token. \(error.localizedDescription)")
        }
    }
}
