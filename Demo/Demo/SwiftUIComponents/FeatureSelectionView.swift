import SwiftUI

struct FeatureSelectionView: View {

    @State private var selectedEnvironment: Environment = DemoSettings.environment
    @State private var selectedIntegration: MerchantIntegration = DemoSettings.merchantIntegration
#if DEBUG
    @State private var manualTestingEnabled: Bool = DemoSettings.manualTesting
#endif

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    Picker("Environment", selection: $selectedEnvironment.onChange(updateEnvironment)) {
                        ForEach(Environment.allCases, id: \.self) { environment in
                            Text(environment.rawValue.capitalized).tag(environment)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker("Merchant Integration", selection: $selectedIntegration.onChange(updateIntegration)) {
                        ForEach(MerchantIntegration.allCases, id: \.self) { integration in
                            Text(integration.displayName).tag(integration)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

#if DEBUG
                    Toggle("Manual SSID Testing (stub APIs)", isOn: $manualTestingEnabled.onChange(updateManualTesting))
#endif
                }

                Section(header: Text("Features")) {
                    NavigationLink {
                        CardPaymentView()
                            .navigationTitle("Card Payment")
                    } label: {
                        Text("Card Payment")
                    }
                    NavigationLink {
                        CardVaultView()
                            .navigationTitle("Card Vaulting")
                    } label: {
                        Text("Card Vaulting")
                    }
                    NavigationLink {
                        PayPalWebPaymentsView()
                            .navigationTitle("PayPal Web")
                    } label: {
                        Text("PayPal Web")
                    }
                    NavigationLink {
                        PayPalVaultView()
                            .navigationTitle("PayPal Vaulting")
                    } label: {
                        Text("PayPal Vaulting")
                    }
                    NavigationLink {
                        SwiftUIPaymentButtonDemo()
                    } label: {
                        Text("Payment Button")
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Feature Selection")
            }
        }
    }

    func updateEnvironment(newEnvironment: Environment) {
        DemoSettings.environment = newEnvironment
    }

    func updateIntegration(newIntegration: MerchantIntegration) {
        DemoSettings.merchantIntegration = newIntegration
    }

#if DEBUG
    func updateManualTesting(isEnabled: Bool) {
        DemoSettings.manualTesting = isEnabled
    }
#endif
}

extension Binding {

    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
