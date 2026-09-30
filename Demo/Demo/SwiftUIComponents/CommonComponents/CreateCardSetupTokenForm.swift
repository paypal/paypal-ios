import SwiftUI
import PayPalPayments

struct CreateCardSetupTokenForm: View {

    let isLoading: Bool
    let onSubmit: (_ request: DemoCreateCardSetupTokenRequest) -> Void

    @State var request = DemoCreateCardSetupTokenRequest()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault without Purchase requires creation of setup token:")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            FloatingLabelTextField(
                placeholder: "Vault Customer ID (Optional)", text: $request.customerID)
            SegmentedEnumPicker(label: "SCA", selection: $request.sca)
                .frame(height: 48)
            ZStack {
                ButtonWithProgress(label: "Checkout", isLoading: isLoading) {
                    onSubmit(request)
                }
            }
        }
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = .systemBlue
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor.white], for: .selected
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
