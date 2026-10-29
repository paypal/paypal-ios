import Foundation
import CorePayments
import VenmoPayments

@MainActor
class VenmoViewModelV2: ObservableObject {

    func checkout(amount: String) async {
    }

    func completeTransaction() async {
    }

    func handleReturnURL(_ url: URL) {
    }

    func resetState() {
    }

    private func fetchOrder(amount: String) async throws -> Order {
        throw NSError(domain: "TODO: implement", code: 123)
    }
}
