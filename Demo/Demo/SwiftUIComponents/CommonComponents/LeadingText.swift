import SwiftUI

struct LeadingText: View {

    var text: String
    var weight: Font.Weight?

    var body: some View {
        Text(text)
            .fontWeight(weight)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    init(_ text: String, weight: Font.Weight? = nil) {
        self.text = text
        self.weight = weight
    }
}
