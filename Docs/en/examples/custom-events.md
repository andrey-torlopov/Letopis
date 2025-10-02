# Custom Event Types

## Defining Event Types

```swift
enum CustomEventType: String, EventTypeProtocol {
    case authentication = "auth"
    case dataSync = "data_sync"
    case featureFlag = "feature_flag"
}

enum CustomAction: String, EventActionProtocol {
    case enable = "enable"
    case disable = "disable"
    case refresh = "refresh"
}
```

## Using Custom Types

```swift
logger
    .event(CustomEventType.authentication)
    .action(CustomAction.enable)
    .info("Two-factor authentication enabled")
```

## Domain-Specific Example

```swift
// E-commerce domain
enum EcommerceEventType: String, EventTypeProtocol {
    case product = "product"
    case cart = "cart"
    case checkout = "checkout"
    case payment = "payment"
}

enum EcommerceAction: String, EventActionProtocol {
    case view = "view"
    case add = "add"
    case remove = "remove"
    case purchase = "purchase"
}

// Usage
logger
    .event(EcommerceEventType.product)
    .action(EcommerceAction.view)
    .payload(["product_id": "12345", "category": "electronics"])
    .analytics("Product viewed")

logger
    .event(EcommerceEventType.cart)
    .action(EcommerceAction.add)
    .payload(["product_id": "12345", "price": "299.99"])
    .analytics("Added to cart")

logger
    .event(EcommerceEventType.payment)
    .action(EcommerceAction.purchase)
    .priority(.critical)
    .payload(["order_id": "ORD-789", "amount": "299.99"])
    .analytics("Purchase completed")
```

## UI Navigation Example

```swift
enum ScreenEventType: String, EventTypeProtocol {
    case navigation = "navigation"
    case userInteraction = "user_interaction"
}

enum ScreenAction: String, EventActionProtocol {
    case open = "open"
    case close = "close"
    case tap = "tap"
    case swipe = "swipe"
}

// Usage
logger
    .event(ScreenEventType.navigation)
    .action(ScreenAction.open)
    .payload(["screen": "ProfileViewController", "from": "HomeViewController"])
    .info("Screen opened")

logger
    .event(ScreenEventType.userInteraction)
    .action(ScreenAction.tap)
    .payload(["button": "logout", "screen": "ProfileViewController"])
    .info("Button tapped")
```

## Best Practices

1. **Use meaningful names**: Choose names that clearly describe the event
2. **Keep it consistent**: Use the same event types across your app
3. **Make it extensible**: Design types that can grow with your app
4. **Document your types**: Add comments explaining when to use each type
5. **Group related types**: Use separate enums for different domains

---

[Back to Documentation Index](../index.md)
