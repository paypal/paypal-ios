# Pay with Card

Accept card payments in your app using the PayPal In-App Payments SDK.

## How it works

The Payments SDK allows for merchant apps to integrate easily with PayPal payment services on both the client and server.

You will need a server integration to create an order and capture the funds using [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). The Payments SDK allows for client-side approval of an order with the user's card information.

## Eligibility
```
# Placeholder: Product Eligibility
what kind of merchants are we targetting?
what features do we offer right now/what features are we missing?
```

## Integration methods

- [Card Fields UI Integration](#card-fields-ui-integration)
- [Fully Customizable Integration](#fully-customizable-integration)

## Card Fields UI Integration

Accept card payments using our card fields UI

```
# Placeholder: Include images of card fields
```

**Requirements:**
Card fields UI offers a low effort integration where you can use our card fields UI, and our card fields will handle ...

## Fully Customizable Integration

Process card payments with PayPal Payments SDK using your own UI.

### Steps

#### 1. Create an order
Call `v2/checkout/orders` to create an order an obtain an order ID

> NOTE: field values enclosed in angle brackets '<>' are placeholders

```
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <Access-Token>' \
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

##### Additional Links

- [PayPal Developer: Get Started – Get an access token](https://developer.paypal.com/api/rest/#link-getanaccesstoken)
- [PayPal Developer: Orders – Create an order](https://developer.paypal.com/api/orders/v2/#orders_createe)

#### 2. Approve the order using Payments SDK:

```swift
import PaymentsSDK

// Create a config object using your clientID obtained from PayPal application portal
let config = CoreConfig(clientID: "<CLIENT_ID>", environment: .sandbox)

// Create a CardClient to approve an order with a card payment method
let cardClient = CardClient(config: config)

// Create a card object
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

// Create a CardRequest and approve the order using buyer's card when buyer submit their card info.
let cardRequest = CardRequest(orderID: "<ORDER_ID>", card: card)
cardClient.approveOrder(request: cardRequest) { result in
    switch result {
        case .success(let result):
            // Order was successfully approved with the card and is ready to be captured/authorized.
        case .failure(let error):
            // Encountered error when approving order.
    }
}
```

#### 3. Capture/authorize the order
Call `v2/checkout/orders/<ORDER_ID>/authorize` to place funds on hold:

```
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<orderID>/authorize' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <access_token>' \
--data-raw ''
```

Call `v2/checkout/orders/<ORDER_ID>/capture` to capture funds immediately:

```
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<orderID>/capture' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <access_token>' \
--data-raw ''
```

