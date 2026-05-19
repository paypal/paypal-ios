import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Protocol defining the interface for confirming payment sources on checkout orders.
protocol CheckoutOrderConfirming {

    func confirmPaymentSource(cardRequest: CardRequest) async throws -> ConfirmPaymentSourceResponse
}
