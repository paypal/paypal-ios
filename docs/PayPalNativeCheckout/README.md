# Accepting PayPal Native Checkout Payments

The PayPal Native Checkout module in the PayPal SDK enables PayPal payments via a native UI experience in your app.

Follow these steps to add PayPal Native Checkout payments:

1. [Setup a PayPal Developer Account](#setup-a-paypal-developer-account)
2. [Add PayPal Native Checkout Module](#add-paypal-native-checkout-module)
3. [Test and go live](#test-and-go-live)
4. After initial setup, Follow instructions [here](#billing-agreement) for Billing Agreements

## Setup a PayPal Developer Account

You will need to set up authorization to use the PayPal Payments SDK. 
Follow the steps in [Get Started](https://developer.paypal.com/api/rest/#link-getstarted) to create a client ID. 

You will need a server integration to create an order to capture funds using the [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). 
For initial setup, the `curl` commands below can be used as a reference for making server-side RESTful API calls.

## Add PayPal Native Checkout Module

### 1. Add the PayPal Native checkout to your app

#### Swift Package Manager

In Xcode, add the PayPal SDK as a [package dependency](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) to your Xcode project. Enter https://github.com/paypal/iOS-SDK as the package URL. Tick the "PayPalNativeCheckout" checkbox to add the PayPal Native Checkout package to your app.

In your app's source code files, use the following import syntax to include the PayPal Native Checkout module:

```swift
import PayPalNativeCheckout
```

#### CocoaPods

Include the PayPal Native Checkout pod in your `Podfile`.

```ruby
pod 'PayPalNativeCheckout'
```

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PayPalNativeCheckout
```

### 2. Initiate the Payments SDK

Create a `CoreConfig` using an [access token](../../README.md#access-token):

```swift
let config = CoreConfig(accessToken: "<ACCESS_TOKEN>", environment: .sandbox)
```

Create a `PayPalNativeCheckoutClient` to approve an order with a PayPal payment method:

```swift
let payPalClient = PayPalNativeCheckoutClient(config: config)
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

To start the PayPal Native checkout flow, call the `start` function in `PayPalNativeCheckoutClient`, with the `CreateOrderCallback` and set the order ID from [step 3](#3-create-an-order) in `createOrderActions`: 

```swift
payPalClient.start { createOrderAction in
    createOrderAction.set(orderId: orderID)
}
```

Implement `PayPalNativeCheckoutDelegate` to listen for result notifications from the SDK. In this example, we implement it in a view model:

```swift
extension MyViewModel: PayPalNativeCheckoutDelegate {

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult approvalResult: Approval) {
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

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalNativeCheckoutClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
        // called when the user decides to change the address or the shipping method of the order.
    }
}
```

For a working example please refer to [PayPalViewModel](../../Demo/Demo/ViewModels/PayPalViewModel.swift) in our Demo application

### 5. Capture/Authorize the order

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

## Billing Agreement

### 1. Create Order

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <ACCESS_TOKEN>' \
--data-raw '{
  "description": "Billing Agreement",
  "shipping_address":
  {
    "line1": "1350 North First Street",
    "city": "San Jose",
    "state": "CA",
    "postal_code": "95112",
    "country_code": "US",
    "recipient_name": "John Doe"
  },
  "payer":
  {
    "payment_method": "PAYPAL"
  },
  "plan":
  {
    "type": "MERCHANT_INITIATED_BILLING",
    "merchant_preferences":
    {
      "return_url": "https://example.com/return",
      "cancel_url": "https://example.com/cancel",
      "notify_url": "https://example.com/notify",
      "accepted_pymt_type": "INSTANT",
      "skip_shipping_address": false,
      "immutable_shipping_address": true
    }
  }
}'
```

**Response**

```json
{
   "token_id": "<TOKEN>"
}
```
### 2. Set BillingAgreement token

```swift
payPalClient.start { createOrderAction in
    createOrderAction.set(billingAgreementToken: "<billingAgreementToken>")
}
```
### 3. Approve the order
Follow steps here to [Approve the order using the Payments SDK](#4-approve-the-order-using-the-payments-sdk)

**Note**: Be sure that the endpoint you are calling aligns with the intent set on the order created in [step 3](#3-initiate-the-payments-sdk).

## Test and go live

### 1. Test the PayPal integration

Follow the [Create sandbox account](https://developer.paypal.com/api/rest/#link-createsandboxaccounts) instructions to create a PayPal test account.
When prompted to login with PayPal during the payment flow on your mobile app, you can log in with the test account credentials created above to complete the Sandbox payment flow. 

### 2. Go live with your integration

Follow [these instructions](https://developer.paypal.com/api/rest/production/) to prepare your integration to go live.

