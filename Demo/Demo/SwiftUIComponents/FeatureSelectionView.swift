import SwiftUI

enum Feature: Int {
    case cardPayment
    case cardVaulting
    case payPalWeb
    case payPalVaulting
    case paymentButtons
}

struct FeatureSelectionView: View {

    @State private var selectedEnvironment: DemoEnvironment = DemoSettings.environment
    @State private var selectedIntegration: MerchantIntegration = DemoSettings.merchantIntegration
    
    #if DEBUG
    @State private var lastCommittedEnvironment: DemoEnvironment = DemoSettings.environment
    @State private var showCustomEnvironmentSheet = false
    #endif
    
    @State private var path: [Feature] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(header: Text("Settings")) {
                    Picker("Environment", selection: $selectedEnvironment.onChange(updateEnvironment)) {
                        ForEach(DemoEnvironment.allCases, id: \.self) { environment in
                            Text(environment.rawValue.capitalized).tag(environment)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    #if DEBUG
                    if selectedEnvironment == .custom {
                        Button("Setup Environment") {
                            showCustomEnvironmentSheet = true
                        }
                    }
                    #endif

                    Picker("Merchant Integration", selection: $selectedIntegration.onChange(updateIntegration)) {
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
                    CardVaultViewV2()
                        .navigationTitle("Card Vaulting")
                        .environment(CardVaultViewModelV2())
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
            #if DEBUG
            .sheet(isPresented: $showCustomEnvironmentSheet) {
                CustomEnvironmentView(
                    onSave: {
                        selectedEnvironment = .custom
                        lastCommittedEnvironment = .custom
                    },
                    onCancel: {
                        if DemoSettings.customEnvironment != nil {
                            DemoSettings.environment = .custom
                            selectedEnvironment = .custom
                            lastCommittedEnvironment = .custom
                        } else {
                            selectedEnvironment = lastCommittedEnvironment
                        }
                    }
                )
            }
            #endif
        }
    }

    func updateEnvironment(newEnvironment: DemoEnvironment) {
        #if DEBUG
        if newEnvironment == .custom {
            showCustomEnvironmentSheet = true
            return
        }
        #endif
        DemoSettings.environment = newEnvironment
        #if DEBUG
        lastCommittedEnvironment = newEnvironment
        #endif
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
