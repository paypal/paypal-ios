import SwiftUI
import CardPayments

@Observable
class CardPaymentUiState {
    
    var createOrderState: AsyncState<Order> = .idle
    var approveOrderState: AsyncState<CardResult> = .idle
    var completeOrderState: AsyncState<Order> = .idle
}
