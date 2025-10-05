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

### Quick start with console logger

```swift
// Use the static console logger for quick debugging
Letopis.console.log("Quick debug message")
Letopis.console.log("Error occurred", level: .error, event: "network")
```

### Logging with built-in types

```swift
// Use built-in event types
logger
    .event(UserEvents.tap)
    .action(UserAction.click)
    .payload(["button": "submit", "screen": "profile"])
    .info("User clicked button")

// Network request
logger
    .event(NetworkEvents.http)
    .action(NetworkAction.success)
    .payload(["endpoint": "/api/users"])
    .info("Request successful")
```

### Logging with custom types

```swift
logger
    .event(AppEventType.userAction)
    .action(AppEventAction.view)
    .payload(["user_id": "12345", "screen": "profile"])
    .source() // Adds file and line information
    .info("User opened profile screen")
```

### Logging API calls

```swift
logger
    .event(AppEventType.apiCall)
    .action(AppEventAction.fetch)
    .payload(["endpoint": "/api/users/12345", "method": "GET"])
    .info("Fetching user data")
```

### Logging critical errors

```swift
logger
    .event(AppEventType.error)
    .action(AppEventAction.networkFailure)
    .critical()
    .payload(["error_code": "500", "retry_count": "3"])
    .error("Failed to load user data")
```

### Debug messages

```swift
logger
    .event(AppEventType.system)
    .debug("Internal cache updated")
```

**Note:** In this example, the console interceptor only shows info and error messages related to user actions, API calls, and errors. Debug messages and other event types are filtered out.

## Direct calls

If the builder is overkill, you can use direct methods:

```swift
// Log successful purchase
logger.info(
    "Purchase completed successfully",
    isCritical: false,
    payload: ["product_id": "premium_plan", "amount": "9.99"],
    eventType: .analytics,
    eventAction: .purchase
)

// Log error
logger.error(
    "Network request failed",
    isCritical: true,
    payload: ["url": "https://api.example.com/data", "status_code": "404"],
    eventType: .error,
    eventAction: .networkFailure
)
```

## Next steps

- Explore the library's [key features](features.md)
- Learn more about the [architecture](architecture.md)
- Study [advanced examples](examples/basic.md)
- Get familiar with [interceptors](advanced/interceptors.md)

---

[Back to main README](../../README.md) | [Installation](installation.md)
