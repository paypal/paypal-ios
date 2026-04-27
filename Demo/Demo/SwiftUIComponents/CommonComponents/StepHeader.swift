import SwiftUI

struct StepHeader: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
    }
}
