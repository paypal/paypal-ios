import SwiftUI

enum Feature: Int {
    case cardPayment
    case cardVaulting
    case payPalWeb
    case payPalVaulting
    case paymentButtons
}

struct FeatureSelectionView: View {

    @State private var selectedEnvironment: Environment = DemoSettings.environment
    @State private var selectedIntegration: MerchantIntegration = DemoSettings.merchantIntegration

    @State private var path: [Feature] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(header: Text("Settings")) {
                    Picker(
                        "Environment",
                        selection: $selectedEnvironment.onChange(updateEnvironment)
                    ) {
                        ForEach(Environment.allCases, id: \.self) { environment in
                            Text(environment.rawValue.capitalized).tag(environment)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker(
                        "Merchant Integration",
                        selection: $selectedIntegration.onChange(updateIntegration)
                    ) {
                        ForEach(MerchantIntegration.allCases, id: \.self) { integration in
                            Text(integration.displayName).tag(integration)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Features")) {
                    NavigationLink("Card Payment", value: Feature.cardPayment)
                    NavigationLink("Card Vaulting", value: Feature.cardVaulting)
                    NavigationLink("PayPal Web", value: Feature.payPalWeb)
                    NavigationLink("PayPal Vaulting", value: Feature.payPalWeb)
                    NavigationLink("Payment Button", value: Feature.paymentButtons)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Feature Selection")
            }
            .navigationDestination(for: Feature.self) { feature in
                switch feature {
                case .cardPayment:
                    CardPaymentView()
                        .navigationTitle("Card Payment")
                        .environment(CardPaymentViewModel())
                case .cardVaulting:
                    CardVaultView()
                        .navigationTitle("Card Vaulting")
                case .payPalWeb:
                    PayPalWebPaymentsView()
                        .navigationTitle("PayPal Web")
                case .payPalVaulting:
                    PayPalVaultView()
                        .navigationTitle("PayPal Vaulting")
                case .paymentButtons:
                    SwiftUIPaymentButtonDemo()
                }
            }
        }
    }

    func updateEnvironment(newEnvironment: Environment) {
        DemoSettings.environment = newEnvironment
    }

    func updateIntegration(newIntegration: MerchantIntegration) {
        DemoSettings.merchantIntegration = newIntegration
    }
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
