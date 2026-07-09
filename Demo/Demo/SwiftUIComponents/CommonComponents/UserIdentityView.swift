import SwiftUI

enum UserIdentitySelection: String, CaseIterable {
    case none = "None"
    case buyerHints = "Email/Phone"
    case ssid = "SSID"
}

struct UserIdentityView: View {

    @Binding var selectedUserIdentity: UserIdentitySelection
    @Binding var email: String
    @Binding var phone: String
    @Binding var ssid: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User Identity (optional)")
                .font(.subheadline)
                .foregroundColor(.primary)
            Picker("User Identity", selection: $selectedUserIdentity) {
                ForEach(UserIdentitySelection.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            switch selectedUserIdentity {
            case .none:
                EmptyView()
            case .buyerHints:
                FloatingLabelTextField(placeholder: "Email (optional)", text: $email, keyboardType: .emailAddress)
                    .autocapitalization(.none)
                FloatingLabelTextField(placeholder: "Phone (optional)", text: $phone, keyboardType: .phonePad)
            case .ssid:
                FloatingLabelTextField(placeholder: "Server-side Shopper Session ID", text: $ssid)
            }
        }
    }
}
