import SwiftUI

struct CheckBoxView: View {
    
    @Binding var checked: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.black, lineWidth: 2)
                .frame(width: 24, height: 24)
            Image(systemName: checked ? "checkmark" : "")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
        }
        .onTapGesture {
            checked.toggle()
        }
    }
}

struct CheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View {
        CheckBoxView(checked: .constant(true))
    }
}
