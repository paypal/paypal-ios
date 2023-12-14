import SwiftUI

// TODO: Move this to a shared space once all modules are converted

struct SuccessViewText: View {

    var titleText: String
    var bodyText: String

    var body: some View {
        HStack {
            Text(titleText).fontWeight(.bold)
            Text(bodyText)
        }    }

    init(_ titleText: String, bodyText: String) {
        self.titleText = titleText
        self.bodyText = bodyText
    }
}
