# What This Guide Will Cover

This guide will walk you through how to integrate the PayPal Checkout flows. With these steps, you will be able to integrate the following payment methods for 1-time checkout:

- PayPal
- PayPal Pay Later
- PayPal Credit

The checkout experience is browser-based and is launched on top of your app's current screen as an in-context experience. On iOS, the SDK utilizes an `ASWebAuthenticationSession` for a secure experience. 

Additionally, you can use the provided customizable PayPal buttons within your app to fit your app’s user experience. The PayPal Mobile SDK offers a button for each payment-type (PayPal, PayPal Pay Later, and PayPal Credit).

# Reference Code

If you prefer to dive into real-world code examples, refer to the GitHub repos below for an end-to-end demo app:

- [iOS demo app](https://github.com/paypal-examples/paypal-ios-sdk-demo-app)
- [Android demo app](https://github.com/paypal-examples/paypal-android-sdk-demo-app)
- [Demo server](https://github.com/paypal-examples/paypal-mobile-sdk-demo-server)

# Know Before You Code

Before beginning the integration steps, you will need to [create a developer account](https://www.paypal.com/webapps/mpp/account-selection?intent=developer&country.x=US&locale.x=en_US) to get the credentials needed to use PayPal services. PayPal uses both the Client ID and Client Secret to interact with the APIs and SDKs; both of which can be found in the [developer dashboard](https://developer.paypal.com/dashboard/applications/sandbox).

> The Client ID and Client Secret are both tied to a PayPal “REST API Application” on the developer site. A default application is created for you when you create a developer account but you can create a new REST API Application by navigating to the [“Apps & Credentials” tab on the developer site](https://developer.paypal.com/dashboard/applications/sandbox).

> The Client ID authenticates your account with PayPal and identifies your app while the Client Secret authorizes your app. Keep the Client Secret safe and don’t share it.

In addition to integrating with the client-side SDK, you will also need a server-side API to complete the integration tasks that are not client-safe. Each of the integration steps below will clearly define where you need to complete the step (app-side or server-side).

# PayPal Checkout Overview

In order to get the most out of this guide, it’s important to first understand the PayPal checkout process.

> PayPal checkout utilizes the [Orders API](https://developer.paypal.com/docs/api/orders/v2/) to create and manage a PayPal Order. An Order represents a payment between two or more parties; and with it, you can manage your customer’s transaction. It is the fundamental object used for managing checkout on PayPal’s platform. For more information on Orders and how to use the API, please refer to the [Orders API reference](https://developer.paypal.com/docs/api/orders/v2/).

PayPal checkout high-level steps:

1. From the mobile app, the merchant calls an endpoint on their server to create a PayPal Order and returns the Order ID to the mobile app.
1. The PayPal SDK uses the Order’s ID to trigger the presentation of the “Review Your Purchase” page via an `ASWebAuthenticationSession` on iOS and `Chrome Custom Tab` on Android. This allows the customer to review and approve (or cancel) the purchase.
1. The customer approves the Order on the “Review Your Purchase” page.
1. The merchant authorizes or captures the Order on their server (see the below note for information on authorizing and capturing an order).

> After an Order is approved by the buyer, the Order must either be “authorized” or “captured” in order to process the money movement. If you want to charge the customer immediately, you must “capture” the order. In contrast, if you need to secure the funds on the customer’s account but don’t want to fully charge the account until a later time, you will want to “authorize” the order. Note that if you “authorize” an order, it will need to be eventually “captured” as well for the funds to be moved to your account.
>
> Consider “capturing” an Order when you can provide your product to your customer immediately (i.e. a digital purchase) and consider “authorizing” an Order when there is a delay for when you can provide the product to your customer (i.e. purchasing a physical product that needs to be processed and shipped). In the latter case, make sure you capture the Order at an appropriate time. For example, you can authorize the order when your customer purchases the item and capture the order when you ship the product.

# Integration Steps

This guide is organized in three phases. Namely:

1. Client Setup - Set up the SDK and UI components
1. Server Implementation - Create the necessary backend endpoints
2. Connect - Connect the frontend and backend components by calling the server endpoints from the app

> **Note:** This guide utilizes SwiftUI for building UI in the sample client-side code and node.js (using express.js) to build the sample server.

## Phase 1: Client Setup

### Step 1. Add the PayPal iOS SDK Dependency

The first step is to add a dependency to the PayPal iOS SDK. This is supported either via Swift Package Manager or CocoaPods. Select the dependency manager of your choice below for the relevant steps:

**Option 1: Swift Package Manager (recommended)**

If you're using Swift Package Manager (SPM), follow the below steps to integrate the SDK:

1. Open your application with Xcode.
1. Add a package dependency using this [guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).
    - Use `https://github.com/paypal/paypal-ios/` as the repository URL.
    - Select the packages you want to include in your target. Include at least:
        - `PayPalWebPayments`
        - `CorePayments`
        - `PaymentButtons`

**Option 2: Cocoapods**

If you're using Cocoapods, include (at least) the following packages in your Podfile:

- `PayPalWebPayments`
- `CorePayments`
- `PaymentButtons`

Please refer to the Podfile below:

```
# Podfile
pod 'PayPal/PayPalWebPayments'
pod 'PayPal/CorePayments'
pod 'PayPal/PaymentButtons'
```

### Step 2. Create a PayPalWebCheckoutClient

After you add a dependency to the PayPal SDK, the next step is to initialize a `PayPalWebCheckoutClient`. The `PayPalWebCheckoutClient` is your interface to start not only the PayPal checkout experience, but also Pay Later and PayPal Credit checkout experiences. In order to initialize the client, you will need to provide a `CoreConfig` object with the following information:

- `clientID`: The Client ID that is tied to the REST API app created in the [developer dashboard](https://developer.paypal.com/dashboard/applications/sandbox).
- `environment`: The environment you want to process payments in. For now, you’ll want to set it to `sandbox` for testing purposes. However, when you’re ready to go to production, you will set it to `live`.

You can initialize this `PayPalWebCheckoutClient` anywhere it makes sense for your application. In this example, we have instantiated in the Cart flow where checkout will be initiated.

```Swift
struct CartView: View {
    private let paypalConfig: CoreConfig
    private let paypalClient: PayPalWebCheckoutClient

    init() {
        paypalConfig = CoreConfig(
            clientID: "<YOUR_CLIENT_ID_HERE>",
            environment: .sandbox // When you're ready for production, change this to `.live`
        )
        paypalClient = PayPalWebCheckoutClient(config: paypalConfig)
    }

    // Other code...
}
```

### Step 3. Display the PayPal Button

The next step is to display a PayPal button in your app. Here, you have a few options depending on the checkout flow you are interested:

- Use a `PayPalButton` if you want PayPal checkout.
- Use a `PayPalPayLaterButton` if you want the Pay Later flow.
- Use a `PayPalCreditButton` if you want the PayPal Credit flow.

> **Note:** Before using PayPal Pay Later and PayPal Credit, make sure it's available in the region you operate by navigating to [this page](https://developer.paypal.com/docs/checkout/payment-methods/).

Additionally, the PayPal SDK offers buttons that can be customized to match the styling of your app - configure the button with the predefined color options, shape, and more!

In terms of placement, place the button anywhere that makes sense for your app (ex: in the cart, in the item detail page, or any other page). In this example, we will place a `PayPalButton` in the `CartView`.

```Swift
struct CartView: View {
    // ...Other code

    var body: some View {
        PayPalButton.Representable() {
            // We'll implement the body of this function in Phase 3
        }
    }
}
```

## Phase 2: Server Implementation

In order to integrate the PayPal Mobile SDK, you will also need to create a few server-side endpoints to perform actions that are not client-safe.

This guide uses the PayPal Server SDK to simplify the server-side steps and we highly recommend using our Server SDKs in your setup. In the examples below, we are using the Javascript Server SDK; however, we have Server SDKs for many different languages. You can learn more about the Server SDKs [here](https://developer.paypal.com/serversdk/java/getting-started/how-to-get-started). If however you prefer to call the PayPal APIs directly, you can find more information in the Orders API reference page [here](https://developer.paypal.com/docs/api/orders/v2/#orders_create).

### Step 4. Install the PayPal Server SDK & Basic Server SDK Setup

With the first order of business, we'll need to install the PayPal Server SDK. In our case, we're using a node.js API built using express.js. Therefore, we'll install the Server SDK using the following command in the project's root directory:

```
npm install @paypal/paypal-server-sdk
```

Next, we need to import the necessary objects from the SDK and setup the `Client` and `OrdersController` objects. You can place the following code where it makes sense within your code structure. For the purposes of this guide, we have placed it in the entrypoint file (i.e. `app.js`/`index.js`).

```Javascript
// Import the PayPal Server SDK
import { Client, Environment, OrdersController } from '@paypal/paypal-server-sdk';

// Setup the PayPal Server SDK Client
const sdkClient = new Client({
    clientCredentialsAuthCredentials: {
        oAuthClientId: "<YOUR_CLIENT_ID_HERE>" // Ideally, you get this from the environment like so: `process.env.PAYPAL_CLIENT_ID`,
        oAuthClientSecret: "<YOUR_CLIENT_SECRET_HERE>" // Ideally, you get this from the environment like so: `process.env.PAYPAL_CLIENT_SECRET`
    },
    environment: Environment.Sandbox, // When you're ready for production, change this to `.live`
});

// Create an OrdersController object
const ordersController = new OrdersController(sdkClient);
```

### Step 5. Create the Order Creation Endpoint

On your server, you will need to create an endpoint that creates a PayPal Order. An Order represents a payment between two or more parties; and with it, you can manage your customer's transaction. It is the fundamental object used for managing checkout on PayPal’s platform. For more information on Orders, please refer to the [Orders API reference](https://developer.paypal.com/docs/api/orders/v2/).

When creating an Order, at minimum, you need to provide the following two things in the request body:

1. `intent`: The value of this field is either `CAPTURE` or `AUTHORIZE` and it simply indicates whether the payment should be immediately “captured” (i.e. charge the customer immediately) or “authorized” (i.e. secure the funds on the customer’s account but don’t fully charge the account). Note that if you “authorize” an order, it will need to be eventually “captured” as well to complete the Order and to move the funds from your customer's account to your account.
2. `purchase_unit`: In it’s simplest form, this field represents the currency and the amount of the transaction as an “amount” object. For example, if the order total for a transaction is $129.99 US Dollars, you would specify the currency code of “USD” and the amount of “129.99” in this field. Note that this field is an array of amount objects since you can specify more than one purchase unit. For more information on purchase units, please refer to the [Orders API reference page](https://developer.paypal.com/docs/api/orders/v2/#orders_create). For a list of supported currencies, please visit [this reference page](https://developer.paypal.com/api/rest/reference/currency-codes/).

To implement the Order creation endpoint, refer to the following code:

```Javascript
// Create a Create Order endpoint
app.post('/paypal/checkout/order', createOrderAsync);

// Create a function to create the order
async function createOrderAsync(req, res) {
    const order = req.body;
    
    if (!order) {
        res.status(400).send({ message: 'Order is empty.' });
        return;
    }
    
    try {
        const response = await ordersController.createOrder({
            body: {
                intent: order.paymentIntent,
                purchaseUnits: [
                    {
                        amount: {
                            currencyCode: order.currencyCode,
                            value: `${getOrderTotal(order.items)}`
                        }
                    }
                ]
            }
        });

        const jsonResponse = JSON.parse(response.body);
        
        res.status(response.statusCode).json(jsonResponse);
    } catch (error) {
        console.error('Failed to create order:', error);
        res.status(400).send({ error: 'Failed to create order.' });
    }
}

function getOrderTotal(orderItems) {
    let amount = 0;

    orderItems.forEach((item) => {
        amount += item.price;
    });

    return amount;
}
```

### Step 6. Create the Capture/Authorize Endpoint

Once your customer approves the transaction, you can either capture or authorize the order. However, you will first need to create a new endpoint on your server to complete the transaction. Whichever option you choose, just note that it must match the `intent` that was set in the previous step when you created the Order. For example, if you set the intent as `AUTHORIZE`, then you must authorize the Order in this step. Similarily, if you set the `intent` to `CAPTURE`, you will need to capture the payment in this step. You can reference the code samples here for examples for both the `CAPTURE` and `AUTHORIZE` flows. However, for the purposes of this guide, we will use the `CAPTURE` flow.

```Javascript
app.post('/order/:orderId/authorize', authorizeOrderAsync);
app.post('/order/:orderId/capture', captureOrderAsync);

async function authorizeOrderAsync(req, res) {
    const { orderId } = req.params;
    
    try {
        const response = await ordersController.authorizeOrder({ id: orderId });
        const jsonResponse = JSON.parse(response.body);

        res.status(response.statusCode).send(jsonResponse);
    } catch (error) {
        console.error('Failed to authorize order:', error);
        res.status(400).send({ message: 'Failed to authorize order.' });
    }
}

async function captureOrderAsync(req, res) {
    const { orderId } = req.params;
    
    try {
        const response = await ordersController.captureOrder({ id: orderId });
        const jsonResponse = JSON.parse(response.body);

        res.status(response.statusCode).send(jsonResponse);
    } catch (error) {
        console.error('Failed to capture order:', error);
        res.status(400).send({ message: 'Failed to capture order.' });
    }
}
```

This step marks the completion for the server-side work. We can now call the newly created endpoints from the app to complete the integration.

## Phase 3: Connect the App to the Backend

Now that we have the server side component complete, we need to call the newly created APIs from the app. Follow the new set of steps to complete the integration.

### Step 7. Implement Create Order

In `CartView`, create a `createOrder()` function that will call your newly created Order creation endpoint. The request and response objects will vary depending on how you prefer to interact with your API. In this example, we created the following request and response objects:

```Swift
// Create Order Request
struct CreateOrderRequest: Encodable {
    let currencyCode: String
    let paymentIntent: PaymentIntent
    let items: [Item]
}

enum PaymentIntent: String, Encodable {
    case authorize = "AUTHORIZE"
    case capture = "CAPTURE"
}
```

```Swift
// Create Order Response
struct CreateOrderResponse: Decodable {
    let id: String
    let status: String
}
```

```Swift
// Function to call your create Order endpoint
private func createOrder() async throws -> CreateOrderResponse {
    // You can find the `Network` class in the "Complete Code Reference" section at the end
    try await Network.post(
        urlString: "<YOUR_CREATE_ORDER_ENDPOINT_URL>", // This is your endpoint that creates the order on the server-side.
        body: CreateOrderRequest( // This is a sample request body. You can make this object however your endpoint expects it to be.
            currencyCode: "USD", // Can be any supported currency code
            paymentIntent: "CAPTURE", // Can be "AUTHORIZE" or "CAPTURE"
            items: cartItems
        )
    )
}
```

### Step 8. Start the PayPal Checkout Flow

Once you have created an Order, you will use the returned Order ID to start the PayPal Checkout flow. This is the part of the SDK that initializes an `ASWebAuthenticationSession` and displays the web view to allow your customers to approve the transaction.

In `CartView`, create a `launchPayPalCheckout(orderId: String)` function that takes the `orderId` returned by the `createOrder()` function as a parameter:

```Swift
private func launchPayPalCheckout(orderId: String) async throws -> PayPalWebCheckoutResult {
    let request = PayPalWebCheckoutRequest(orderID: orderId, fundingSource: .paypal)
    return try await paypalClient.start(request: request)
}
```

### Step 9. Complete the Transaction

Finally, after your user approves the transaction, you will need to either "authorize" or "capture" the Order by calling the appropriate endpoint from the ones you created in the server-side steps portion of this guide. In this example, we'll implement the capture flow:

```Swift
private func captureOrder(orderId: String) async throws -> CaptureOrderResponse {
    try await Network.post(
        urlString: "<YOUR_CAPTURE_OR_AUTHORIZE_ORDER_ENDPOINT_URL>" // This is your endpoint that captures or authorizes the order on the server-side.
    )
}
```

The `CaptureOrderResponse` response object will vary depending on how you prefer to interact with your API. In this example, `CaptureOrderResponse` is defined as the following:

```Swift
struct CaptureOrderResponse: Decodable {
    let id: String
    let status: String
    var paymentSource: PaymentSource?
}
```

### Step 10. Complete the PayPal Button's Action

Now that we have implemented all the functions to interact with your API, we need to go back to our button code and call all the functions:

```Swift
struct CartView: View {
    var body: some View {
        Task {
            let checkoutWasSuccessful = await paypalButtonClicked()
            if checkoutWasSuccessful {
                print("Success!")
            } else {
                print("Failed to complete checkout.")
            }
        }
    }

    private func paypalButtonClicked() async -> Bool {
        do {
            let createOrderResponse = try await createOrder()
            let checkoutResult = try await launchPayPalCheckout(orderId: createOrderResponse.id)
            let _ = try await captureOrder(orderId: checkoutResult.orderID)

            print("Checkout Succeeded. OrderId \(createOrderResponse.id).")
            return true
        } catch {
            print("Checkout Failed. ERROR: \(error)")
            return false
        }
    }
}
```

### Step 11. Handle Success

Once you have either captured or authorized the payment, you have completed all the steps to provide PayPal Checkout for your customers. At this point, you can show an order confirmation view to your customers!

> Remember that if you chose to authorize the payment (instead of capture it), you will need to capture the payment at a later time to complete the order.

# Complete Code Reference

## Client-side Code

```Swift
struct CartView: View {
    private let paypalConfig: CoreConfig
    private let paypalClient: PayPalWebCheckoutClient

    init() {
        paypalConfig = CoreConfig(
            clientID: "<YOUR_CLIENT_ID_HERE>",
            environment: .sandbox // When you're ready for production, change this to `.live`
        )
        paypalClient = PayPalWebCheckoutClient(config: paypalConfig)
    }

    var body: some View {
        Task {
            let checkoutWasSuccessful = await paypalButtonClicked()
            if checkoutWasSuccessful {
                print("Success!")
            } else {
                print("Failed to complete checkout.")
            }
        }
    }

    private func createOrder() async throws -> CreateOrderResponse {
        try await Network.post(
            urlString: "<YOUR_CREATE_ORDER_ENDPOINT_URL>", // This is your endpoint that creates the order on the server-side.
            body: CreateOrderRequest( // This is a sample request body. You can make this object however your endpoint expects it to be.
                currencyCode: "USD", // Can be any supported currency code
                paymentIntent: "CAPTURE", // Can be "AUTHORIZE" or "CAPTURE"
                items: cartItems
            )
        )
    }

    private func paypalButtonClicked() async -> Bool {
        do {
            let createOrderResponse = try await createOrder()
            let checkoutResult = try await launchPayPalCheckout(orderId: createOrderResponse.id)
            let _ = try await captureOrder(orderId: checkoutResult.orderID)

            print("Checkout Succeeded. OrderId \(createOrderResponse.id).")
            return true
        } catch {
            print("Checkout Failed. ERROR: \(error)")
            return false
        }
    }

    private func launchPayPalCheckout(orderId: String) async throws -> PayPalWebCheckoutResult {
        let request = PayPalWebCheckoutRequest(orderID: orderId, fundingSource: .paypal)
        return try await paypalClient.start(request: request)
    }

    private func captureOrder(orderId: String) async throws -> CaptureOrderResponse {
        try await Network.post(
            urlString: "<YOUR_CAPTURE_OR_AUTHORIZE_ORDER_ENDPOINT_URL>" // This is your endpoint that captures or authorizes the order on the server-side.
        )
    }
}
```

```Swift
// Create Order Request
struct CreateOrderRequest: Encodable {
    let currencyCode: String
    let paymentIntent: PaymentIntent
    let items: [Item]
}
```

```Swift
enum PaymentIntent: String, Encodable {
    case authorize = "AUTHORIZE"
    case capture = "CAPTURE"
}
```

```Swift
// Create Order Response
struct CreateOrderResponse: Decodable {
    let id: String
    let status: String
}
```

```Swift
struct CaptureOrderResponse: Decodable {
    let id: String
    let status: String
    var paymentSource: PaymentSource?
}
```

```Swift
struct PaymentSource: Codable, Equatable {
    let card: Card?
    let paypal: PayPal?
    struct PayPal: Codable, Equatable {
        let emailAddress: String
        let accountId: String
        let accountStatus: String
        let name: Name
        let address: Address
        enum CodingKeys: String, CodingKey {
            case emailAddress = "email_address"
            case accountId = "account_id"
            case accountStatus = "account_status"
            case name = "name"
            case address = "address"
        }
        struct Name: Codable, Equatable {
            let givenName: String
            let surname: String
            enum CodingKeys: String, CodingKey {
                case givenName = "given_name"
                case surname = "surname"
            }
        }
        struct Address: Codable, Equatable {
            let countryCode: String
            enum CodingKeys: String, CodingKey {
                case countryCode = "country_code"
            }
        }
    }
    struct Card: Codable, Equatable {
        let lastDigits: String?
        let brand: String?
        let attributes: Attributes?
    }
    struct Attributes: Codable, Equatable {
        let vault: Vault
    }
    struct Vault: Codable, Equatable {
        let id: String
        let status: String
        let customer: Customer
    }
    struct Customer: Codable, Equatable {
        let id: String
    }
}
```

```Swift
struct Network {
    static let API_BASE_URL = "<BASE_URL_FOR_YOUR_SERVER_API>"
    static func post<T: Decodable> (urlString: String, body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw AppError.urlError
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
                (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) else {
            throw AppError.apiError
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

## Server-side Code

```Javascript
import express from 'express';
import 'dotenv/config';

// Import the PayPal Server SDK
import { Client, Environment, OrdersController } from '@paypal/paypal-server-sdk';

const port = 8765 // Ideally, you get this via the environment like so: `process.env.PORT`

// Setup the PayPal Server SDK Client
const sdkClient = new Client({
    clientCredentialsAuthCredentials: {
        oAuthClientId: "<YOUR_CLIENT_ID_HERE>" // Ideally, you get this from the environment like so: `process.env.PAYPAL_CLIENT_ID`,
        oAuthClientSecret: "<YOUR_CLIENT_SECRET_HERE>" // Ideally, you get this from the environment like so: `process.env.PAYPAL_CLIENT_SECRET`
    },
    environment: Environment.Sandbox, // When you're ready for production, change this to `.live`
});

// Create an OrdersController object
const ordersController = new OrdersController(sdkClient);

// Create the endpoints
app.post('/paypal/checkout/order', createOrderAsync);
app.post('/order/:orderId/authorize', authorizeOrderAsync);
app.post('/order/:orderId/capture', captureOrderAsync);

// Create a function to create the order
async function createOrderAsync(req, res) {
    const order = req.body;
    
    if (!order) {
        res.status(400).send({ message: 'Order is empty.' });
        return;
    }
    
    try {
        const response = await ordersController.createOrder({
            body: {
                intent: order.paymentIntent,
                purchaseUnits: [
                    {
                        amount: {
                            currencyCode: order.currencyCode,
                            value: `${getOrderTotal(order.items)}`
                        }
                    }
                ]
            }
        });

        const jsonResponse = JSON.parse(response.body);
        
        res.status(response.statusCode).json(jsonResponse);
    } catch (error) {
        console.error('Failed to create order:', error);
        res.status(400).send({ error: 'Failed to create order.' });
    }
}

function getOrderTotal(orderItems) {
    let amount = 0;

    orderItems.forEach((item) => {
        amount += item.price;
    });

    return amount;
}

async function authorizeOrderAsync(req, res) {
    const { orderId } = req.params;
    
    try {
        const response = await ordersController.authorizeOrder({ id: orderId });
        const jsonResponse = JSON.parse(response.body);

        res.status(response.statusCode).send(jsonResponse);
    } catch (error) {
        console.error('Failed to authorize order:', error);
        res.status(400).send({ message: 'Failed to authorize order.' });
    }
}

async function captureOrderAsync(req, res) {
    const { orderId } = req.params;
    
    try {
        const response = await ordersController.captureOrder({ id: orderId });
        const jsonResponse = JSON.parse(response.body);

        res.status(response.statusCode).send(jsonResponse);
    } catch (error) {
        console.error('Failed to capture order:', error);
        res.status(400).send({ message: 'Failed to capture order.' });
    }
}
```