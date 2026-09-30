import SwiftUI

// Ref: https://www.swiftbysundell.com/tips/creating-custom-swiftui-container-views/
struct FormGroup<Content: View>: View {

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 16, content: content)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray, lineWidth: 2)
                    .padding(8)
            )
    }
}
