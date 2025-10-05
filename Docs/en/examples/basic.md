# Basic Usage Examples

## Simple Logging

```swift
import Letopis

let logger = Letopis(interceptors: [ConsoleInterceptor()])

logger.info("Application started")
logger.warning("Low memory warning")
logger.error("Failed to load data")
logger.debug("Cache cleared")
```

## With Event Types

```swift
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
    case error = "error"
    case system = "system"
}

logger
    .event(AppEventType.userAction)
    .info("User tapped login button")
```

## With Actions

```swift
enum AppEventAction: String, EventActionProtocol {
    case view = "view"
    case fetch = "fetch"
    case networkFailure = "network_failure"
}

logger
    .event(AppEventType.apiCall)
    .action(AppEventAction.fetch)
    .info("Fetching user profile")
```

## With Payload

```swift
logger
    .event(AppEventType.userAction)
    .payload(["user_id": "12345", "screen": "profile"])
    .info("User viewed profile")
```

## With Source Information

```swift
logger
    .event(AppEventType.error)
    .source() // Adds file, function, and line info
    .error("Unexpected nil value")
```

## Complete Example

```swift
logger
    .event(AppEventType.apiCall)
    .action(AppEventAction.fetch)
    .critical()
    .payload([
        "endpoint": "/api/users/12345",
        "method": "GET",
        "retry_count": "3"
    ])
    .source()
    .error("API request failed after retries")
```

## Logging Errors

```swift
do {
    try performNetworkRequest()
} catch {
    logger
        .event(AppEventType.error)
        .critical()
        .error(error)
}
```

## Filtered Console Output

```swift
let logger = Letopis(
    interceptors: [
        ConsoleInterceptor(
            logTypes: [.info, .error], // Only info and error
            eventTypes: ["user_action", "api_call"], // Only these types
            criticalOnly: true // Only critical events
        )
    ]
)

// This will be logged
logger.event("user_action").critical().info("Login")

// This will be filtered out (debug type)
logger.event("system").debug("Cache updated")

// This will be filtered out (non-critical)
logger.event("user_action").info("Button clicked")
```

---

[Back to Documentation Index](../index.md)
