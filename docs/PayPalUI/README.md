# Pay using PayPal UI

1. [Add PayPal UI](#add-paypal-ui)

## Add PayPal UI

### 1. Add the PayPalUI to your app

#### Swift Package Manager

In Xcode, follow the guide to [add package dependencies to your app](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) and enter https://github.com/paypal/iOS-SDK as the repository URL. Select the checkboxes for each specific PayPal library you wish to include in your project.

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PayPalUI
```

#### CocoaPods

Include the PayPal pod in your `Podfile`.

```ruby
pod 'PayPal'
```

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PayPalUI
```

### 2. Render PayPal buttons
The PayPalUI module allows you to render three buttons that can offer a set of customizations like color, edges, size and labels:
* `PayPalButton`: generic PayPal button
* `PayPalPayLater`: a PayPal button with a fixed PayLater label
* `PayPalCredit`: a PayPal button with the PayPalCredit logo

You can use any button in both `UKit` and `SwiftUI` as follows:

#### UKit

```swift
class MyViewController: ViewController {

    lazy var payPalButton: PayPalButton = {
        let payPalButton = PayPalButton()
        payPalButton.addTarget(self, action: #selector(payPalButtonTapped), for: .touchUpInside)
        return payPalButton
    }()
    
    @objc func paymentButtonTapped() {
        // Insert your code here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(payPalButton)
    }
}
```

#### SwiftUI

```swift
struct MyApp: View {
    @ViewBuilder
    var body: some View {
        VStack {
            PayPalButton() {
                // Insert your code here
            }
        }
    }
}
```
