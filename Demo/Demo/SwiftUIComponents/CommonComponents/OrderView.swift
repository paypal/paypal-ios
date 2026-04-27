import SwiftUI

struct OrderView: View {
    
    let order: Order
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(order.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(order.status)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}

