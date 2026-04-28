import SwiftUI

struct ScrollAnchor: View {
    
    let id: String
    var body: some View {
        Spacer()
            .id(id)
            .frame(height: 0)
    }
}
