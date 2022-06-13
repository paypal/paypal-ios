# Accepting Card Payments

The Card module in the PayPal SDK enables Credit and Debit card payments in your app.

Follow these steps to add Card payments:

1. [Setup a PayPal Developer Account](#setup-a-paypal-developer-account)
1. [Add Card Module](#add-card-module)
1. [Test and go live](#test-and-go-live)

## Setup a PayPal Developer Account

You will need to set up authorization to use the PayPal Payments SDK. 
Follow the steps in [Get Started](https://developer.paypal.com/api/rest/#link-getstarted) to create a client ID and generate an access token. 

You will need a server integration to create an order and capture the funds using [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). 
For initial setup, the `curl` commands below can be used in place of a server SDK.

## Add Card Module

### 1. Add the Payments SDK  to your app

#### Swift Package Manager

In Xcode, add the PayPal SDK as a package dependency to your Xcode project. Enter https://github.com/paypal/iOS-SDK as the package URL. Tick the "Card" checkbox to add the Card package to your app.

In your app's source code files, use the following import syntax to include the PayPal Card module:

```swift
import Card
```

#### CocoaPods

Include the PayPal pod in your `Podfile`.

```ruby
pod 'PayPal'
```

In your app's source files, use the following import syntax to include PayPal's Card library:

```swift
import Card
```

### 2. Initiate the Payments SDK

Create a `CoreConfig` using your client ID from the PayPal Developer Portal:

```swift
let config = CoreConfig(clientID: "<CLIENT_ID>", environment: .sandbox)
```

Create a `CardClient` to approve an order with a Card payment method:

```swift
let cardClient = CardClient(config: config)
```

### 3. Create an order

When a user enters the payment flow, call `v2/checkout/orders` to create an order and obtain an order ID:

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

The `id` field of the response contains the order ID to pass to your client.

### 4. Create a request containing the card payment details

Create a `Card` object containing the user's card details.

```Swift
let card = Card(
    number: "4111111111111111",
    expirationMonth: "01",
    expirationYear: "25",
    securityCode: "123",
    cardholderName: "Jane Smith",
    billingAddress: Address(
        addressLine1: "123 Main St.",
        addressLine2: "Apt. 1A",
        locality: "city",
        region: "IL",
        postalCode: "12345",
        countryCode: "US"
    )
)
```

Attach the card and the order ID from [step 3](#3-create-an-order) to a `CardRequest`.

```swift
let cardRequest = CardRequest(orderID: "<ORDER_ID>", card: card)
```

### 5. Approve the order using Payments SDK

Approve the order using your `CardClient`.

Call `CardClient#approveOrder` to approve the order, and then handle results:

```swift
Task {
    do {
        let result = cardClient.approveOrder(request: cardRequest)
        // order was successfully approved and is ready to be captured/authorized (see step 6)
    } catch {
        // handle the error by accessing `error.localizedDescription`
    }
}
```

### 6. Capture/authorize the order

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

## Testing and Go Live

### 1. Test the Card integratoin

TODO - Do we have test card numbers merchants can test this with?

### 2. Go live with your integration

Follow [these instructions](https://developer.paypal.com/api/rest/production/) to prepare your integration to go live.

