import SwiftUI

// TODO: Add PayPal button once buttons are updated as SwiftUI accessible views

@available(iOS 13.0.0, *)
struct SwiftUIPayPalDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            Text("WIP - PayPal View")
        }
    }
}

struct SwiftUIPayPalView_Previews: PreviewProvider {

    static var previews: some View {
        SwiftUIPayPalDemo()
    }
}
