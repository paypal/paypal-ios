import SwiftUI

struct CardVaultView: View {

    // MARK: Views
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    Text("Hello")
                }
            }
        }
    }
}

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
