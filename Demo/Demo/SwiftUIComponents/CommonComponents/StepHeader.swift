import SwiftUI

struct StepHeader: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
