import SwiftUI

@available(iOS 13.0.0, *)
struct SwiftUICardDemoView: View {

    @State private var cardFormIsComplete: Bool = false

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        SwiftUIRepresentable()
    }
}

@available(iOS 13, *)
struct SwiftUIRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = FeatureBaseViewController()
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // not needed currently
    }
}

@available(iOS 13.0.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUICardDemoView()
    }
}
