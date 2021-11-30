import SwiftUI

@available(iOS 13, *)
struct FeatureBaseViewControllerRepresentable: UIViewControllerRepresentable {

    var baseViewModel: BaseViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        FeatureBaseViewController(baseViewModel: baseViewModel)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // not needed currently
    }
}
