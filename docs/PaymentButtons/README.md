# Pay using PaymentButtons

1. [Add PaymentButtons](#add-payment-buttons)

## Add Payment Buttons

### 1. Add the PaymentButtons to your app

#### Swift Package Manager

In Xcode, follow the guide to [add package dependencies to your app](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) and enter https://github.com/paypal/paypal-ios as the repository URL. Tick the `PaymentButtons` checkbox to add the Payment Buttons library to your app.

#### CocoaPods

Include the `PaymentButtons` sub-mobule in your `Podfile`.

```ruby
pod 'PayPal/PaymentButtons'
```

### 2. Render PayPal buttons
The PayPalUI module allows you to render three buttons that can offer a set of customizations like color, edges, size and labels:
* `PayPalButton`: generic PayPal button
* `PayPalPayLater`: a PayPal button with a fixed PayLater label
* `PayPalCredit`: a PayPal button with the PayPalCredit logo

Each button as a `UKit` and `SwiftUI` implementation as follows:

    | UIKit      | SwiftUI |
    | ----------- | ----------- |
    | PayPalButton      | PayPalButton.Representable       |
    | PayPalCreditButton   | PayPalCreditButton.Representable        |
    | PayPalPayLaterButton   | PayPalPayLaterButton.Representable        |
> Note: label customization only applies to `PayPalButton` when its size is `.expanded` or `.full`

#### UKit

```swift
import PaymentButtons

class MyViewController: ViewController {

    lazy var payPalButton: PayPalButton = {
        let payPalButton = PayPalButton()
        payPalButton.addTarget(self, action: #selector(payPalButtonTapped), for: .touchUpInside)
        return payPalButton
    }()
    
    @objc func payPalButtonTapped() {
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
import PaymentButtons

struct MyApp: View {
    @ViewBuilder
    var body: some View {
        VStack {
            PayPalButton.Representable() {
                // Insert your code here
            }
        }
    }
}
```
