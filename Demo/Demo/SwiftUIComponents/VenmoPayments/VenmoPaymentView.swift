import SwiftUI

struct VenmoPaymentView: View {
    
    @ObservedObject var venmoPaymentsViewModel = VenmoPaymentsViewModel()
    
    var body: some View {
        Text("Hello, Venmo!")
    }
}

#Preview {
    VenmoPaymentView()
}
