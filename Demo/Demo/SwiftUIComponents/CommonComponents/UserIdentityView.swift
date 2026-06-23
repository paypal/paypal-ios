import SwiftUI

// TODO: Replace with PayPalUserIdentity from SDK when feature/shopper-session-id merges
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
                .foregroundColor(.secondary)
            Picker("User Identity", selection: $selectedUserIdentity) {
                Text("None").tag(UserIdentitySelection.none)
                Text("Email/Phone").tag(UserIdentitySelection.buyerHints)
                Text("SSID").tag(UserIdentitySelection.ssid)
            }
            .pickerStyle(SegmentedPickerStyle())
            switch selectedUserIdentity {
            case .none:
                EmptyView()
            case .buyerHints:
                TextField("Email (optional)", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                TextField("Phone (optional)", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
            case .ssid:
                TextField("Server-side Shopper Session ID", text: $ssid)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
            }
        }
    }
}
