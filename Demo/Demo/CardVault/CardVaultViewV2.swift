import SwiftUI

struct CardVaultViewV2: View {
    
    @Environment(CardVaultViewModelV2.self)
    var viewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Text("Hellooooo")
                }
            }
        }
    }
}

