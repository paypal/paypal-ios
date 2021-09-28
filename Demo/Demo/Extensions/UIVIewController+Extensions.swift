import UIKit

extension UIViewController {

    func button(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        return button
    }

    func textField(
        placeholder: String? = nil,
        defaultValue: String? = nil,
        clearButton: UITextField.ViewMode = .never
    ) -> UITextField {
        let result = UITextField()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.borderStyle = .roundedRect
        result.placeholder = placeholder
        result.text = defaultValue
        result.clearButtonMode = clearButton
        if let textDelegate = self as? UITextFieldDelegate {
            result.delegate = textDelegate
        }
        return result
    }
}
