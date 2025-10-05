If the builder is overkill, call the facade methods directly.

## Available Methods

All methods accept optional `isCritical`, `payload`, `eventType`, and `eventAction` arguments that are merged into the final payload.

### `info(_:isCritical:payload:eventType:eventAction:)`

Log informational messages:

```swift
logger.info(
    "Purchase completed successfully",
    isCritical: false,
    payload: ["product_id": "premium_plan", "amount": "9.99", "currency": "USD"],
    eventType: .analytics,
    eventAction: .purchase)
```

### `warning(_:isCritical:payload:eventType:eventAction:)`

Log warnings:

```swift
logger.warning(
    "API rate limit approaching",
    isCritical: true,
    payload: ["remaining_requests": "10", "reset_time": "60s"])
```

### `error(_:isCritical:payload:eventType:eventAction:)`

Log error messages or Error objects (defaults to `isCritical: true`):

```swift
// With string
logger.error(
    "Network request failed",
    isCritical: true,
    payload: ["url": "https://api.example.com/data", "status_code": "404"],
    eventType: .error,
    eventAction: .networkFailure)

// With Error object
do {
    try riskyOperation()
} catch {
    logger.error(error, isCritical: true)
}
```

### `debug(_:isCritical:payload:eventType:eventAction:)`

Log debug information:

```swift
logger.debug(
    "Cache state",
    payload: ["entries": "150", "size": "2.5MB"])
```

### `analytics(_:isCritical:payload:eventType:eventAction:)`

Log analytics events:

```swift
logger.analytics(
    "User signed up",
    payload: ["source": "email", "plan": "free"],
    eventType: .analytics)
```

## Convenience Methods

For quick logging without creating custom event types:

```swift
// Simple log with level
logger.log("App started", level: .info)

// With criticality
logger.log("Payment failed", level: .error, isCritical: true)

// With event and action
logger.log(
    "User action", 
    level: .info, 
    event: "button_tap", 
    action: "checkout"
)

// Error logging
logger.log(networkError, isCritical: true, event: "network")
```

## When to Use Direct Methods

Direct methods are useful when:

- You need to log a simple message quickly
- You don't need the flexibility of the builder
- You're migrating from another logging system
- Performance is critical (slightly less overhead)

---

[Back to Documentation Index](../index.md)
