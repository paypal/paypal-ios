# Accepting PayPal Web Checkout Payments

The PayPal Web Checkout module in the PayPal SDK enables PayPal payments in your app.

Follow these steps to add PayPal Web Checkout payments:

1. [Setup a PayPal Developer Account](#setup-a-paypal-developer-account)
1. [Add PayPal Web Checkout Module](#add-paypal-web-checkout-module)
1. [Test and go live](#test-and-go-live)

## Setup a PayPal Developer Account

You will need to set up authorization to use the PayPal Payments SDK. 
Follow the steps in [Get Started](https://developer.paypal.com/api/rest/#link-getstarted) to create a client ID. 

You will need a server integration to create an order to capture funds using the [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). 
For initial setup, the `curl` commands below can be used as a reference for making server-side RESTful API calls.

## Add PayPal Web Checkout Module

### 1. Add the Payments SDK  to your app

#### Swift Package Manager

In Xcode, add the PayPal SDK as a [package dependency](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) to your Xcode project. Enter https://github.com/paypal/iOS-SDK as the package URL. Tick the "PayPalWebCheckout" checkbox to add the PayPal Web Checkout package to your app.

In your app's source code files, use the following import syntax to include the PayPal Card module:

```swift
import PayPalWebCheckout
```

#### CocoaPods

Include the PayPal Web Checkout pod in your `Podfile`.

```ruby
pod 'PayPalWebCheckout'
```

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PayPalWebCheckout
```

### 2. Configure your application to present an authentication session

The PayPal Web Checkout module uses an [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) to complete the payment flow.

Make sure your `ViewController` conforms to the `ASWebAuthenticationPresentationContextProviding` protocol:

```swift
extension MyViewController: ASWebAuthenticationPresentationContextProviding {

    // MARK: - ASWebAuthenticationPresentationContextProviding
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        ?? ASPresentationAnchor()
    }
}
```

### 3. Initiate the Payments SDK

Create a `CoreConfig` using your Client ID from the PayPal Developer Portal:

```swift
let config = CoreConfig(clientID: "<CLIENT_ID>", environment: .sandbox)
```

Create a `PayPalWebCheckoutClient` to approve an order with a PayPal payment method:

```swift
let payPalClient = PayPalWebCheckoutClient(config: config)
```

### 4. Create an order

When a user enters the payment flow, call `v2/checkout/orders` to create an order and obtain an Order ID:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic <ENCODED_CLIENT_ID>' \
--data-raw '{
    "intent": "<CAPTURE|AUTHORIZE>",
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

The `id` field of the response contains the Order ID to pass to your client.

### 5. Create a request object for launching the PayPal flow

Configure your `PayPalWebCheckoutRequest` and include the order ID generated in [step 4](#4-create-an-order):

```swift
let payPalRequest = PayPalWebCheckoutRequest(orderID: "<ORDER_ID>")
```

You can also specify one of the follwing funding sources for your order: `PayPal (default)`, `PayLater` or `PayPalCredit`.
> Click [here](https://developer.paypal.com/docs/checkout/pay-later/us/) for more information on PayPal Pay Later

### 6. Approve the order using the Payments SDK

To start the PayPal Web Checkout flow, call `payPalWebCheckoutClient.start(payPalWebCheckoutRequest)`.

Implement `PaypalWebCheckoutDelegate` in your `ViewController` to listen for result notifications from the SDK:

```swift
extension MyViewController: PayPalWebCheckoutDelegate {

    func checkoutWithPayPal() {
        payPalClient.delegate = self
        payPalClient.start(request: payPalRequest, context: self)
    }

    // MARK: - PayPalWebCheckoutDelegate
    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult) {
        // order was successfully approved and is ready to be captured/authorized (see step 7)
    }

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        // handle the error by accessing `error.localizedDescription`
    }

    func payPalDidCancel(_ payPalClient: PayPalWebCheckoutClient) {
        // the user canceled
    }
}
```

### 7. Capture/Authorize the order

If you receive a successful result in the client-side flow, you can then capture or authorize the order. 

Call `authorize` to place funds on hold:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<ORDER_ID>/authorize' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic <ENCODED_CLIENT_ID>' \
--data-raw ''
```

Call `capture` to capture funds immediately:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<ORDER_ID>/capture' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic <ENCODED_CLIENT_ID>' \
--data-raw ''
```

**Note**: Be sure that the endpoint you are calling aligns with the intent set on the order created in [step 3](#3-initiate-the-payments-sdk).

## Test and go live

### 1. Test the PayPal integration

Follow the [Create sandbox account](https://developer.paypal.com/api/rest/#link-createsandboxaccounts) instructions to create a PayPal test account.
When prompted to login with PayPal during the payment flow on your mobile app, you can log in with the test account credentials created above to complete the Sandbox payment flow. 

### 2. Go live with your integration

Follow [these instructions](https://developer.paypal.com/api/rest/production/) to prepare your integration to go live.

