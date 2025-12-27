# Quick Start

This guide will help you get started with Letopis in just a few minutes.

## Import the library

```swift
import Letopis
```

## Use built-in domains and actions

Letopis provides ready-to-use domains and actions for common scenarios:

```swift
import Letopis

// Built-in domains:
// - UserDomain: ui, input, navigation, gesture
// - NetworkDomain: network, api, websocket
// - ErrorDomain: validation, network, parsing, business, system, auth, database
// - LifecycleDomain: screen, app, component, session

// Built-in actions for each domain:
// - UserAction: click, longPress, scroll, submit, swipeLeft, etc.
// - NetworkAction: start, success, failure, retry, timeout, etc.
// - ErrorAction: occurred, recovered, retrying, fatal, etc.
// - LifecycleAction: willAppear, didAppear, willLoad, didLoad, etc.

// You can also create your own custom domains and actions
enum PaymentDomain: String, DomainProtocol {
    case payment = "payment"
    case subscription = "subscription"
}

enum PaymentAction: String, ActionProtocol {
    case initiated = "initiated"
    case completed = "completed"
    case failed = "failed"
}
```

## Initialize the logger

Setup the logger with a console interceptor for development:

```swift
private let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(
            // Filter by severity
            severities: [.info, .error, .warning],
            // Filter by purpose
            purposes: [.operational, .analytics],
            // Filter by domains (event types)
            eventTypes: ["ui", "network", "payment"],
            // Filter by actions
            actions: ["click", "success", "failed"]
        )
    ],
    // Configure global sensitive keys for automatic masking
    sensitiveKeys: ["password", "token", "api_key", "ssn"]
)
```

## Usage examples

### Direct Methods API (Quick and Simple)

For quick logging without metadata, use direct methods:

```swift
// Simple messages
logger.info("Application started")
logger.warning("API rate limit approaching")
logger.error("Failed to load user data")
logger.debug("Internal cache updated")

// With basic payload
logger.info(
    "User opened profile screen",
    payload: ["user_id": "12345", "screen": "profile"]
)

// With domain and action (using strings)
logger.info(
    "User opened profile screen",
    domain: "ui",
    action: "screen_opened",
    payload: ["screen": "profile"]
)

// With protocol-based domain and action
logger.info(
    "API request completed",
    domain: NetworkDomain.api,
    action: NetworkAction.success,
    payload: ["endpoint": "/users"]
)
```

### DSL API (Recommended for Rich Logging)

For expressive, structured logging with metadata, use the fluent DSL:

```swift
// Use built-in domains and actions
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .payload(["button": "submit", "screen": "profile"])
    .info("User clicked button")

// Network request
logger.log()
    .domain(NetworkDomain.api)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Request successful")

// Lifecycle event
logger.log()
    .domain(LifecycleDomain.screen)
    .action(LifecycleAction.didAppear)
    .payload(["screen_name": "profile"])
    .info("Screen appeared")

// Logging with source location
logger.log()
    .domain(UserDomain.ui)
    .action(UserAction.click)
    .payload(["button": "checkout"])
    .source() // Adds file, function, and line information
    .info("User tapped checkout")

// Logging critical errors
logger.log()
    .domain(ErrorDomain.network)
    .action(ErrorAction.fatal)
    .critical()
    .payload(["error_code": "500", "retry_count": "3"])
    .error("Failed to load user data")

// String-based domains for custom events
logger.log()
    .domain("payment")
    .action("completed")
    .payload(["amount": "99.99", "currency": "USD"])
    .info("Payment processed successfully")

// Sensitive data masking (enabled by default)
logger.log()
    .domain("auth")
    .action("login_success")
    .payload(["user_id": "12345", "token": "abc123xyz"])
    .info("User logged in")
// Output: user_id=12345, token=a***z (token is masked automatically)
```

**Note:** The console interceptor filters events based on configured severities, purposes, domains, and actions. Events that don't match the filters are ignored.

## Next steps

- Explore the library's [key features](features.md)
- Learn more about the [architecture](architecture.md)
- Study [advanced examples](examples/basic.md)
- Get familiar with [interceptors](advanced/interceptors.md)

---

[Back to main README](../../README.md) | [Installation](installation.md)
