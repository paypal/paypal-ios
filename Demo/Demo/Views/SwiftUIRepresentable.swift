import SwiftUI

@available(iOS 13, *)
struct SwiftUIRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        FeatureBaseViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // not needed currently
    }
}
