import UIKit

class CustomTextField: UITextField {
    convenience init(placeholderText: String? = nil, defaultValue: String? = nil) {
        self.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        borderStyle = .roundedRect
        placeholder = placeholderText
        text = defaultValue
        clearButtonMode = .never
        if let textDelegate = self as? UITextFieldDelegate {
            delegate = textDelegate
        }
    }
}
