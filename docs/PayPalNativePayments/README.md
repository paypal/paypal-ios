# Accepting PayPal Native Payments

The PayPal Native Payments module in the PayPal SDK enables PayPal payments via a native UI experience in your app.

Follow these steps to add PayPal Native Payments:

1. [Setup a PayPal Developer Account](#setup-a-paypal-developer-account)
2. [Add PayPal Native Payments Module](#add-paypal-native-payments-module)
3. [Test and go live](#test-and-go-live)
4. After initial setup, Follow instructions [here](#billing-agreement) for Billing Agreements

## Setup a PayPal Developer Account

You will need to set up authorization to use the PayPal Payments SDK. 
Follow the steps in [Get Started](https://developer.paypal.com/api/rest/#link-getstarted) to create a client ID. 

You will need a server integration to create an order to capture funds using the [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). 

## Add PayPal Native Payment Module

### 1. Add the PayPal Native payments to your app

#### Swift Package Manager

In Xcode, add the PayPal SDK as a [package dependency](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) to your Xcode project. Enter https://github.com/paypal/iOS-SDK as the package URL. Tick the `PayPalNativePayments` checkbox to add the PayPal Native Payments library to your app.

#### CocoaPods

Include the `PayPalNativePayments` sub-module in your `Podfile`:

```ruby
pod 'PayPal/PayPalNativePayments'
```

### 2. Initiate the Payments SDK

Create a `CoreConfig` using an [access token](../../README.md#access-token):

```swift
let config = CoreConfig(accessToken: "<ACCESS_TOKEN>", environment: .sandbox)
```

Create a `PayPalNativeCheckoutClient` to approve an order with a PayPal payment method:

```swift
let paypalNativeClient = PayPalNativeCheckoutClient(config: config)
```

### 3. Create an order

When a user initiates a payment flow, call `v2/checkout/orders` to create an order and obtain an order ID:

**Request**
```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <ACCESS_TOKEN>' \
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

**Response**
```json
{
   "id":"<ORDER_ID>",
   "status":"CREATED"
}
```

The `id` field of the response contains the order ID to pass to your client.

### 4. Approve the order using the Payments SDK

To start the PayPal Native checkout flow, call the `start` function on `PayPalNativeCheckoutClient`, with a `PayPalNativeCheckoutRequest` using your order ID from [step 3](#3-create-an-order): 

```swift
let request = PayPalNativeCheckoutRequest(orderID: "<ORDER_ID>")
await paypalNativeClient.start(request: request)
```

Implement `PayPalNativeCheckoutDelegate` to listen for result notifications from the SDK. In this example, we implement it in a view model:

```swift
extension MyViewModel: PayPalNativeCheckoutDelegate {

    func setup() {
        paypalNativeClient.delegate = self
    }

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        // order was successfully approved and is ready to be captured/authorized (see step 5)
    }

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        // handle the error by accessing `error.localizedDescription`
    }

    func paypalDidCancel(_ payPalClient: PayPalNativeCheckoutClient) {
        // the user cancelled
    }

    func paypalWillStart(_ payPalClient: PayPalNativeCheckoutClient) {
        // the paypal pay sheet is about to appear. Handle loading views, spinners, etc.
    }
}
```

For a working example please refer to [PayPalViewModel](../../Demo/Demo/ViewModels/PayPalViewModel.swift) in our Demo application

### 5. Optionally inspect shipping details

You can optionally conform to `PayPalNativeShippingDelegate` to receive notifications when the user updates their shipping address or shipping method details.

```swift
extension MyViewModel: PayPalNativeShippingDelegate {

    func setup() {
        paypalNativeClient.delegate = self         // required
        paypalNativeClient.shippingDelegate = self // optional
    }

    func paypal(
        _ payPalClient: PayPalNativeCheckoutClient,
        didShippingAddressChange shippingAddress: PayPalNativeShippingAddress,
        withAction shippingActions: PayPalNativePaysheetActions
    ) {
        // called when the user updates their chosen shipping address

        // REQUIRED: you must call shippingActions.approve() or shippingActions.reject() in this callback
        shippingActions.approve()

        // OPTIONAL: you can optionally patch your order. Once complete, call shippingActions.approve() if successful or shippingActions.reject() if not.
    }

    func paypal(
        _ payPalClient: PayPalNativeCheckoutClient,
        didShippingMethodChange shippingMethod: PayPalNativeShippingMethod,
        withAction shippingActions: PayPalNativePaysheetActions
    ) {
        // called when the user updates their chosen shipping method

        // REQUIRED: patch your order server-side with the updated shipping amount.
        // Once complete, call `shippingActions.approve()` or `shippingActions.reject()`
        if patchOrder() == .success {
            shippingActions.approve()
        } else {
            shippingActions.reject()
        }
    }
}
```

If you want to show shipping options in the PayPal Native Paysheet, provide `purchase_units[].shipping.options` when creating an orderID with the [`orders/v2` API](https://developer.paypal.com/docs/api/orders/v2/#definition-purchase_unit) on your server. Otherwise, our paysheet UI won't display any shipping options.

### 6. Capture/Authorize the order

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
