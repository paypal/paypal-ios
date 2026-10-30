import SwiftUI

struct VenmoPaymentsView: View {
    
    @Environment(VenmoViewModel.self)
    var viewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateOrderForm(isLoading: false) { request in
                        // TODO: create an order
                    }
                }
            }
        }
    }
}
