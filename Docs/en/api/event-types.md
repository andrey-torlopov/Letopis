# Domains & Actions

Letopis uses a **domain + action** model to structure log events. Domains represent business areas or subsystems, while actions describe specific operations within those domains.

## Built-in Domains and Actions

Letopis provides ready-to-use domains and actions for common scenarios:

### UserDomain - User Interactions

```swift
public enum UserDomain: String, DomainProtocol, Sendable {
    case ui = "ui"
    case input = "user_input"
    case navigation = "user_navigation"
    case gesture = "user_gesture"
}

public enum UserAction: String, ActionProtocol, Sendable {
    case click, longPress, doubleClick, scroll
    case typeText, submit
    case swipeLeft, swipeRight, swipeUp, swipeDown
    case pullToRefresh, pinch, rotate
}
```

### NetworkDomain - Network Operations

```swift
public enum NetworkDomain: String, DomainProtocol, Sendable {
    case network = "network"
    case api = "api"
    case websocket = "websocket"
}

public enum NetworkAction: String, ActionProtocol, Sendable {
    case start, success, failure, retry, cancel, timeout
    case connected, disconnected
    case dataReceived, dataSent
}
```

### ErrorDomain - Error Handling

```swift
public enum ErrorDomain: String, DomainProtocol, Sendable {
    case validation = "validation"
    case network = "network"
    case parsing = "parsing"
    case business = "business"
    case system = "system"
    case auth = "auth"
    case database = "database"
}

public enum ErrorAction: String, ActionProtocol, Sendable {
    case occurred, recovered, retrying, fatal
    case ignored, logged, handledByUser
}
```

### LifecycleDomain - Lifecycle Events

```swift
public enum LifecycleDomain: String, DomainProtocol, Sendable {
    case screen = "screen"
    case app = "app"
    case component = "component"
    case session = "session"
}

public enum LifecycleAction: String, ActionProtocol, Sendable {
    case willAppear, didAppear
    case willDisappear, didDisappear
    case willLoad, didLoad
    case willDestroy, didDestroy
}
```

### Using Built-in Domains

```swift
// Logging user action
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .payload(["button": "submit"])
    .info("User clicked button")

// Logging network request
logger.log()
    .domain(NetworkDomain.api)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Request successful")

// Logging error
logger.log()
    .domain(ErrorDomain.network)
    .action(ErrorAction.retrying)
    .critical()
    .error("Connection error")

// Logging lifecycle event
logger.log()
    .domain(LifecycleDomain.screen)
    .action(LifecycleAction.didAppear)
    .payload(["screen_name": "profile"])
    .info("Screen appeared")
```

## Custom Domains and Actions

You can create your own domains and actions by conforming to the protocols:

```swift
// Define custom domain
enum PaymentDomain: String, DomainProtocol {
    case payment = "payment"
    case subscription = "subscription"
    case billing = "billing"
}

// Define custom actions
enum PaymentAction: String, ActionProtocol {
    case initiated = "initiated"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
}
```

## Using Custom Domains and Actions

```swift
logger.log()
    .domain(PaymentDomain.payment)
    .action(PaymentAction.completed)
    .payload(["amount": "99.99", "currency": "USD"])
    .info("Payment completed successfully")
```

## String-based Domains and Actions

For quick prototyping or simple cases, you can use strings directly:

```swift
logger.log()
    .domain("auth")
    .action("login_success")
    .payload(["user_id": "12345"])
    .info("User logged in")
```

## Best Practices

- Use enums with `String` raw values for type safety
- Make types conform to `Sendable` when working with actors
- Choose descriptive names that reflect your domain
- Keep event taxonomies consistent across your application

---

[Back to Documentation Index](../index.md)
