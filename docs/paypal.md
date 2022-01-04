# Pay with PayPal

Accept PayPal payments in your iOS app using the PayPal Payments SDK.

## How it works

This diagram shows how your client, your server, and PayPal interact:

// TODO - Get a diagram of the payment flow similar to [this](https://developer.paypal.com/braintree/docs/start/overview#how-it-works)

## Eligibility

PayPal is available as a payment method to merchants in multiple [countries and currencies](https://developer.paypal.com/docs/checkout/payment-methods/).

The PayPal iOS SDK supports a minimum deployment target of iOS 13+ and requires Xcode 13+ and macOS Big Sur 11.3+.
iOS apps can be written in Swift 5.1+.
This SDK can be integrated with CocoaPods or Swift Package Manager.

## How to integrate

- [Custom Integration](#technical-steps---custom-integration)

### Know before you code

You will need to set up authorization to use the PayPal Payments SDK. 
Follow the steps in [Get Started](https://developer.paypal.com/api/rest/#link-getstarted) to create a client ID and generate an access token. 
Follow the steps in [Enable the SDK](https://developer.paypal.com/sdk/in-app/android/#link-enablethesdk) to set up your account and application for PayPal payments.

You will need a server integration to create an order and capture the funds using [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). 
For initial setup, the `curl` commands below can be used in place of a server SDK.

### Technical steps - custom integration

#### 1. Add the Payments SDK  to your app

#### Swift Package Manager

To add the PayPal package to your Xcode project, select _File > Swift Packages > Add Package Dependency_ and enter https://github.com/paypal/iOS-SDK as the repository URL. Tick the checkboxes for the specific PayPal libraries you wish to include.

In your app's source code files, use the following import syntax to include PayPal's libraries:

```swift
import PayPal
```

#### CocoaPods

Include the PayPal pod in your `Podfile`.

```ruby
pod 'PayPal'
```

In your app's source code files, use the following import syntax to include PayPal's libraries:

```swift
import PayPal
```

#### 2. Create a PayPal button 

Add a `PayPalButton` to your View:

```swift
let payPalButton = PayPalButton()
```

#### 3. Initiate the Payments SDK

Create a `CoreConfig` using your client ID from the PayPal Developer Portal:

```swift
let config = CoreConfig(clientID: "<CLIENT_ID>", environment: .sandbox)
```

Configure a return URL using your bundle identifier:

```swift
let returnUrl = "<BUNDLE_IDENTIFIER>" + "://paypalpay"
```

Create a `PayPalClient` to approve an order with a PayPal payment method:

```swift
let payPalClient = PayPalClient(config: config, returnURL: returnUrl)
```

#### 4. Create an order

When a user enters the payment flow, call `v2/checkout/orders` to create an order and obtain an order ID:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <ACCESS_TOKEN>' \
--data-raw '{
    "intent": "CAPTURE",
    "purchase_units": [
        {
            "amount": {
                "currency_code": "USD",
                "value": "5.00"
            }
        }
    ]
}'
```

The `id` field of the response contains the order ID to pass to your client.

#### 5. Approve the order through the Payments SDK

When a user taps the PayPal button created above, approve the order using your `PayPalClient`.

Add a target to your PayPal button to launch the PayPal payment flow:

```swift
payPalButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)

@objc func paymentButtonTapped() {
    checkoutWithPayPal(orderID: "<ORDER_ID>")
}
```

Call `PayPalClient.start` to approve the order, and then handle results:

```swift
func checkoutWithPayPal(orderID: String) {
    payPalClient.start(orderID: orderID, presentingViewController: self) { state in
        switch state {
        case .success(let result):
            // capture/authorize the order using `result.orderID` (see step 6)        
        case .failure(let error):
            // handle the error by accessing `error.localizedDescription`
        case .cancellation:
            // the user canceled
        }
    }
}
```

#### 6. Capture/authorize the order

If you receive a successful result in the client-side flow, you can then capture or authorize the order. 

Call `authorize` to place funds on hold:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<ORDER_ID>/authorize' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <ACCESS_TOKEN>' \
--data-raw ''
```

Call `capture` to capture funds immediately:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<ORDER_ID>/capture' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <ACCESS_TOKEN>' \
--data-raw ''
```

### Testing your integration

Follow the [Create sandbox accounts](https://developer.paypal.com/api/rest/#link-createsandboxaccounts) instructions to create PayPal test accounts.
When prompted to login with PayPal during the payment flow on your mobile app, you can log in with the test account credentials created above to complete the Sandbox payment flow. 

### Go live

Follow [these instructions](https://developer.paypal.com/api/rest/production/) to prepare your integration to go live.
