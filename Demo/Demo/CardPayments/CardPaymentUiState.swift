import SwiftUI
import CardPayments

@Observable
class CardPaymentUiState {
    
    var createOrderRequest = DemoCreateOrderRequest()
    var approveOrderRequest = DemoApproveOrderRequest()
    
    var createOrderState: AsyncState<Order> = .idle
    var approveOrderState: AsyncState<CardResult> = .idle
    var completeOrderState: AsyncState<Order> = .idle
}
