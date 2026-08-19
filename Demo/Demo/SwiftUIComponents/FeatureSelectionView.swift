import SwiftUI

struct FeatureSelectionView: View {

    @State private var selectedEnvironment: DemoEnvironment = DemoSettings.environment
    @State private var selectedIntegration: MerchantIntegration = DemoSettings.merchantIntegration
    #if DEBUG
    @State private var lastCommittedEnvironment: DemoEnvironment = DemoSettings.environment
    @State private var showCustomEnvironmentSheet = false
    #endif

    var body: some View {
        NavigationView {
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
