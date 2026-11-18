import SwiftUI

struct CompleteOrderForm: View {

    let intent: Intent
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        let capitalizedIntent = intent.rawValue.capitalized
        FormGroup {
            StepHeader(text: "Complete Order")
            let buttonLabel = "\(capitalizedIntent) Order"
            ButtonWithProgress(label: buttonLabel, isLoading: isLoading) {
                onSubmit()
            }
        }
    }
}
