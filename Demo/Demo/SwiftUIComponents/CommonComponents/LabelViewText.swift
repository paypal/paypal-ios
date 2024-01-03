import SwiftUI

struct LabelViewText: View {

    var titleText: String
    var bodyText: String

    var body: some View {
        HStack {
            Text(titleText).fontWeight(.bold)
            Text(bodyText)
        }
    }

    init(_ titleText: String, bodyText: String) {
        self.titleText = titleText
        self.bodyText = bodyText
    }
}
