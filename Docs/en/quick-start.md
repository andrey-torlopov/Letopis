# Quick Start

This guide will help you get started with Letopis in just a few minutes.

## Import the library

```swift
import Letopis
```

## Use built-in event types

Letopis provides ready-to-use event types for common scenarios:

```swift
// Use built-in types
import Letopis

// UserEvents - for user interactions
// NetworkEvents - for network requests
// ErrorEvents - for error handling

// Or create your own custom types
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
    case error = "error"
    case system = "system"
}

// Actions
enum AppEventAction: String, EventActionProtocol {
    case view = "view"
    case fetch = "fetch"
    case networkFailure = "network_failure"
}
```

## Initialize the logger

Setup the logger with a console interceptor for development:

```swift
private let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(
            // You can specify which events you want to explicitly listen to
            // Otherwise, all events will be processed
            logTypes: [.info, .error],
            eventTypes: ["user_action", "api_call", "error"],
            priorities: [.default, .critical]
        )
    ]
)
```

## Usage examples

### Standard API (Recommended)

The primary way to log is using direct methods with optional parameters:

```swift
// Simple info message
logger.info("Application started")

// With metadata
logger.info(
    "User opened profile screen",
    payload: ["user_id": "12345", "screen": "profile"]
)

// With event type and action
logger.info(
    "User opened profile screen",
    payload: ["user_id": "12345", "screen": "profile"],
    eventType: AppEventType.userAction,
    eventAction: AppEventAction.view
)

// Warning logs
logger.warning(
    "API rate limit approaching",
    payload: ["remaining": "10", "limit": "100"]
)

// Error logs (critical by default)
logger.error(
    "Failed to load user data",
    payload: ["error_code": "500", "retry_count": "3"],
    eventType: AppEventType.error,
    eventAction: AppEventAction.networkFailure
)

// Debug messages with source location
logger.debug("Internal cache updated", includeSource: true)
// Automatically adds file, function, and line number to the log

// Analytics events
logger.analytics(
    "Purchase completed successfully",
    payload: ["product_id": "premium_plan", "amount": "9.99"]
)
```

### Optional DSL API

For users who prefer a fluent, chainable syntax, the DSL API is available:

```swift
// Use built-in event types
logger.log()
    .event(UserEvents.tap)
    .action(UserAction.click)
    .payload(["button": "submit", "screen": "profile"])
    .info("User clicked button")

// Network request
logger.log()
    .event(NetworkEvents.http)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Request successful")

// Logging with custom types
logger.log()
    .event(AppEventType.userAction)
    .action(AppEventAction.view)
    .payload(["user_id": "12345", "screen": "profile"])
    .source() // Adds file and line information
    .info("User opened profile screen")

// Logging critical errors
logger.log()
    .event(AppEventType.error)
    .action(AppEventAction.networkFailure)
    .critical()
    .payload(["error_code": "500", "retry_count": "3"])
    .error("Failed to load user data")
```

**Note:** In this example, the console interceptor only shows info and error messages related to user actions, API calls, and errors. Debug messages and other event types are filtered out.

## Next steps

- Explore the library's [key features](features.md)
- Learn more about the [architecture](architecture.md)
- Study [advanced examples](examples/basic.md)
- Get familiar with [interceptors](advanced/interceptors.md)

---

[Back to main README](../../README.md) | [Installation](installation.md)
