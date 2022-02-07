import Foundation

/// Coordinator class for passing actions to our UIKit buttons in SwiftUI
public class Coordinator {

    var action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    @objc func onAction(_ sender: Any) {
        action()
    }
}
