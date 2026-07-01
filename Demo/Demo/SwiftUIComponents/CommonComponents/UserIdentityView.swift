import SwiftUI
import PayPalWebPayments

extension PayPalUserIdentity {
    var title: String {
        switch self {
        case .none:
            "None"
        case .emailPhone:
            "Email/Phone"
        case .serverSideShopperSession:
            "SSID"
        }
    }
    
    static var all: [PayPalUserIdentity] {
        [.none, .emailPhone(email: nil, phone: nil), .serverSideShopperSession(serverSideShopperSessionId: "")]
    }
}

struct UserIdentityView: View {

    @Binding var selectedUserIdentity: PayPalUserIdentity
    @Binding var email: String
    @Binding var phone: String
    @Binding var ssid: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User Identity (optional)")
                .font(.subheadline)
                .foregroundColor(.primary)
            Picker("User Identity", selection: $selectedUserIdentity) {
                ForEach(PayPalUserIdentity.all, id: \.self) {
                    Text($0.title).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            switch selectedUserIdentity {
            case .none:
                EmptyView()
            case .emailPhone:
                FloatingLabelTextField(placeholder: "Email (optional)", text: $email, keyboardType: .emailAddress)
                    .autocapitalization(.none)
                FloatingLabelTextField(placeholder: "Phone (optional)", text: $phone, keyboardType: .phonePad)
            case .serverSideShopperSession:
                FloatingLabelTextField(placeholder: "Server-side Shopper Session ID", text: $ssid)
            }
        }
    }
}
