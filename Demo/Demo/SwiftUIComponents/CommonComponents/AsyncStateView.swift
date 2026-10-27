import SwiftUI

struct AsyncStateView<T: Hashable, Content: View>: View {
    
    let state: AsyncState<T>
    @ViewBuilder let content: (T) -> Content
    
    init(_ state: AsyncState<T>, @ViewBuilder content: @escaping (T) -> Content) {
        self.state = state
        self.content = content
    }
    
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
