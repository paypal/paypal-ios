import SwiftUI

struct VenmoPaymentView: View {
    
    @StateObject var venmoPaymentsViewModel = VenmoPaymentsViewModel()
    
    var body: some View {
        Text("Hello, Venmo!")
    }
}

#Preview {
    VenmoPaymentView()
}
