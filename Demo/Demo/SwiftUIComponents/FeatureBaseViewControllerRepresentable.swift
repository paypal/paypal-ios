import SwiftUI

struct FeatureBaseViewControllerRepresentable: UIViewControllerRepresentable {

    let baseViewModel: BaseViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        FeatureBaseViewController(baseViewModel: baseViewModel)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // not needed currently
    }
}
