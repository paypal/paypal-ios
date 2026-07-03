#if DEBUG
import SwiftUI

struct CustomEnvironmentView: View {

    @SwiftUI.Environment(\.presentationMode) private var presentationMode

    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var clientID: String
    @State private var restBaseURL: String
    @State private var graphQLBaseURL: String

    init(onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        let config = DemoSettings.customEnvironment
        _clientID = State(initialValue: config?.clientID ?? "")
        _restBaseURL = State(initialValue: config?.restBaseURL ?? "")
        _graphQLBaseURL = State(initialValue: config?.graphQLBaseURL ?? "")
    }

    // MARK: - Validation

    private var trimmedClientID: String {
        clientID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedRestBaseURL: String {
        restBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedGraphQLBaseURL: String {
        graphQLBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var clientIDError: String? {
        trimmedClientID.isEmpty ? "Client ID is required" : nil
    }

    private var restBaseURLError: String? {
        Self.urlError(trimmedRestBaseURL)
    }

    private var graphQLBaseURLError: String? {
        Self.urlError(trimmedGraphQLBaseURL)
    }

    private var isValid: Bool {
        clientIDError == nil && restBaseURLError == nil && graphQLBaseURLError == nil
    }

    private static func urlError(_ value: String) -> String? {
        if value.isEmpty {
            return "URL is required"
        }
        guard let components = URLComponents(string: value),
            let scheme = components.scheme?.lowercased(),
            scheme == "http" || scheme == "https",
            let host = components.host, !host.isEmpty else {
            return "Enter a valid http/https URL"
        }
        return nil
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Client ID")) {
                    TextField("Client ID", text: $clientID)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    errorText(clientIDError)
                }

                Section(header: Text("SDK REST Base URL")) {
                    TextField("https://...", text: $restBaseURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                    errorText(restBaseURLError)
                }

                Section(header: Text("SDK GraphQL Base URL")) {
                    TextField("https://.../graphql", text: $graphQLBaseURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                    errorText(graphQLBaseURLError)
                }
            }
            .navigationTitle("Custom Environment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    @ViewBuilder
    private func errorText(_ message: String?) -> some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
        }
    }

    private func save() {
        guard isValid else {
            return
        }
        DemoSettings.customEnvironment = CustomEnvironmentConfig(
            clientID: trimmedClientID,
            restBaseURL: trimmedRestBaseURL,
            graphQLBaseURL: trimmedGraphQLBaseURL
        )
        DemoSettings.environment = .custom
        onSave()
        presentationMode.wrappedValue.dismiss()
    }
}
#endif
