import SwiftUI

struct UnwrapValueOrError<T: Hashable, Content: View>: View {
    
    let state: AsyncState<T>
    
    @ViewBuilder
    let content: (T) -> Content

    var body: some View {
        switch state {
        case .loaded(let value):
            content(value)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        default:
            EmptyView()
        }
    }
}
